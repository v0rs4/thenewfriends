require 'string_generator'

class ProcessVkContactsWorker
	include ::Sidekiq::Worker

	sidekiq_options :retry => false, :backtrace => true

	class VkConctactsXSLXFileCreator
		CONTACTS_FIELDS = [:id, :first_name, :last_name, :skype, :mobile_phone, :home_phone, :twitter, :instagram]

		class << self
			def create_xlsx_file(vk_contacts, opts = {})
				new(vk_contacts).create_xlsx_file(opts)
			end
		end

		attr_reader :vk_contacts

		def initialize(vk_contacts)
			@vk_contacts = vk_contacts
		end

		# @return [String] File path
		def create_xlsx_file(opts = {})
			file_name = "#{Time.now.strftime('%Y_%m_%d')}"
			file_name = "#{opts[:prefix]}_#{file_name}" if opts[:prefix]
			file_ext = '.xlsx'

			File.join(Rails.root, 'tmp', file_name + file_ext).tap do |xlsx_file_path|
				WriteXLSX.new(xlsx_file_path).tap do |workbook|
					worksheet = workbook.add_worksheet
					CONTACTS_FIELDS.each.each_with_index do |field_name, index|
						worksheet.write(0, index, field_name)
					end
					vk_contacts.each.each_with_index do |contact, row_index|
						if contact.is_a?(Hash)
							contact = Hashie::Mash.new(contact)
							CONTACTS_FIELDS.each.each_with_index do |field_name, col_index|
								worksheet.write(row_index + 1, col_index, contact[field_name])
							end
						else
							raise ArgumentError.new('invalid type of contact')
						end
					end
					workbook.close
				end
			end
		end
	end

	class SaveVkContactsSource
		attr_reader :vk_c_source_name, :vk_c_source_identifier, :opts

		def initialize(vk_c_source_name, vk_c_source_identifier, opts = {})
			@vk_c_source_name = vk_c_source_name
			@vk_c_source_identifier = vk_c_source_identifier
			@opts = opts
		end

		def run
			_save_source
		end

		private

		def _save_source
			if VkContactsSource.exists?(vk_identifier: vk_c_source_identifier)
				VkContactsSource.find_by_vk_identifier(vk_c_source_identifier)
			else
				begin
					VkContactsSource.create!(name: vk_c_source_name, vk_identifier: vk_c_source_identifier)
				rescue ActiveRecord::RecordNotUnique
					VkContactsSource.find_by_vk_identifier(vk_c_source_identifier)
				end
			end
		end
	end

	class SaveVkContactsFiles
		attr_reader :vk_c_source, :vk_contacts_filtered, :user, :opts

		def initialize(vk_contacts_filtered, vk_c_source, opts = {})
			@vk_contacts_filtered = vk_contacts_filtered
			@vk_c_source = vk_c_source
			@user = user
			@opts = opts
		end

		def run
			_save_files
		end

		private

		def _save_files
			files = []
			files << _save_vk_contacts_file
		end

		def _sort_vk_contacts_filtered
			vk_contacts_filtered.inject({ skype: [], phone: [], instagram: [], twitter: [] }) do |_hash, _vk_contact|
				_vk_contact = Hashie::Mash.new(_vk_contact)
				_hash.merge({
						skype: _vk_contact.skype.nil? ? _hash[:skype] << _vk_contact.skype : _hash[:skype],
						phone: _vk_contact.mobile_phone.nil? ? _hash[:phone] << _vk_contact.mobile_phone : _hash[:phone],
						instagram: _vk_contact.instagram.nil? ? _hash[:instagram] << _vk_contact.instagram : _hash[:instagram],
						twitter: _vk_contact.twitter.nil? ? _hash[:twitter] << _vk_contact.twitter : _hash[:twitter]
					})
			end
		end

		def _save_vk_contacts_file
			file_name_prefix = vk_c_source.name
			vk_contacts_file_path = VkConctactsXSLXFileCreator.create_xlsx_file(
				vk_contacts_filtered,
				prefix: file_name_prefix
			)
			vk_conctacs_file_io = File.open(vk_contacts_file_path)
			vk_conctacs_file = __save_vk_contacts_file(file_name_prefix, vk_conctacs_file_io, vk_c_source.id)
			vk_conctacs_file_io.close
			File.delete(vk_contacts_file_path)
			vk_conctacs_file
		end

		def __save_vk_contacts_file(name, file, vk_contacts_source_id)
			if VkContactsFile.exists?(name: name, vk_contacts_source_id: vk_contacts_source_id)
				VkContactsFile.where(name: name, vk_contacts_source_id: vk_contacts_source_id).take(1).first
			else
				begin
					VkContactsFile.create(
						name: name,
						file: file,
						vk_contacts_source_id: vk_contacts_source_id
					)
				rescue ActiveRecord::RecordNotUnique
					VkContactsFile.where(name: name, vk_contacts_source_id: vk_contacts_source_id).take(1).first
				end
			end

		end
	end

	class LinkUserWithVkContactsFiles
		attr_reader :user, :vk_c_files

		def initialize(user, vk_c_files)
			@user, @vk_c_files = user, vk_c_files
		end

		def run
			_link_user_with_vk_c_files
		end

		private

		def _link_user_with_vk_c_files
			vk_c_files.inject([]) do |_links, _vk_c_file|
				unless UserVkContactsFile.exists?(user_id: user.id, vk_contacts_file_id: _vk_c_file.id)
					_links << UserVkContactsFile.create(user_id: user.id, vk_contacts_file_id: _vk_c_file.id)
				end
			end
		end
	end

	class FilterVkContacts
		class << self
			def filter(contacts)
				new.filter(contacts)
			end
		end

		def filter(contacts)
			filter_contacts(contacts)
		end

		private

		def filter_contacts(contacts)
			contacts.delete_if do |contact|
				contact['skype'] = skype_filter(contact['skype'])
				contact['mobile_phone'] = phone_filter(contact['mobile_phone'])
				contact['home_phone'] = phone_filter(contact['home_phone'])
				contact['twitter'] = basic_filter(contact['twitter'])
				contact['instagram'] = basic_filter(contact['instagram'])

				contact['skype'].nil? and contact['mobile_phone'].nil? and contact['home_phone'].nil?
			end
			contacts
		end

		def bullshit?(str)
			str.nil? or str =~ /http/ or str =~ /@/
		end

		def skype_filter(skype)
			unless bullshit?(skype)
				filtered = skype.gsub(/[^A-Za-z0-9\-\_\,\.]/, '')
				filtered if filtered.size.between?(6, 32) and filtered[0] =~ /[A-Za-z]/
			end
		end

		def phone_filter(phone_number)
			unless bullshit?(phone_number)
				number = phone_number.gsub(/[^0-9]/, '')
				if number =~ /\A380\d{9}\z|\A7\d{10}\z|\A375\d{9}\z/
					"+#{number}"
				elsif number =~ /\A80\d{9}\z/
					"+3#{number}"
				elsif number =~ /\A0\d{9}\z/
					"+38#{number}"
				end
			end
		end

		def basic_filter(str)
			unless bullshit?(str)
				str.gsub(/\s/, '')
			end
		end
	end

	def perform(vk_c_source_name, vk_c_source_identifier, vk_contacts_json, user_id)
		vk_contacts_parsed = _parse_contacts(vk_contacts_json)
		vk_contacts_filtered = _filter_vk_contacts(vk_contacts_parsed)
		vk_c_source = _save_vk_contacts_source(vk_c_source_name, vk_c_source_identifier)
		vk_c_files = _save_vk_contacts_files(vk_contacts_filtered, vk_c_source)
		_link_user_with_vk_c_files(User.find(user_id), vk_c_files)
	end

	private

	def _parse_contacts(*args)
		MultiJson.load(*args)
	end

	def _filter_vk_contacts(*args)
		FilterVkContacts.filter(*args)
	end

	def _save_vk_contacts_files(*args)
		SaveVkContactsFiles.new(*args).run
	end

	def _save_vk_contacts_source(*args)
		SaveVkContactsSource.new(*args).run
	end

	def _link_user_with_vk_c_files(*args)
		LinkUserWithVkContactsFiles.new(*args).run
	end
end