require 'string_generator'

class ProcessVkContactsWorker
	include ::Sidekiq::Worker

	sidekiq_options :retry => true, :backtrace => true

	class VkContactsFileCreator
		class VkConctactsSkypeVCFCreator
			attr_reader :vk_contacts

			def initialize(vk_contacts)
				@vk_contacts = vk_contacts.deep_dup
			end

			def create(opts = {})
				file_name = "#{Time.now.strftime('%Y_%m_%d')}"
				file_name = "#{opts[:filename_prefix]}_#{file_name}" if opts[:filename_prefix]
				file_ext = '.vcf'

				File.join(Rails.root, 'tmp', file_name + file_ext).tap do |file_path|
					File.open(file_path, 'w') do |file|
						vk_contacts.each.each_with_index do |contact, row_index|
							contact = Hashie::Mash.new(contact)
							unless contact.skype.nil? or contact.skype.blank?
								file.puts 'BEGIN:VCARD'
								file.puts "N:#{contact.skype}"
								file.puts "X-SKYPE-USERNAME:#{contact.skype}"
								file.puts "END:VCARD"
							end
						end
					end
				end
			end
		end

		class VkConctactsXSLXFileCreator
			CONTACTS_FIELDS = [:id, :first_name, :last_name, :skype, :mobile_phone, :home_phone, :twitter, :instagram]

			attr_reader :vk_contacts

			def initialize(vk_contacts)
				@vk_contacts = vk_contacts.deep_dup
			end

			# @return [String] File path
			def create(opts = {})
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

		def self.create_skype_vcf(vk_contacts, opts = {})
			VkConctactsSkypeVCFCreator.new(vk_contacts).create(opts)
		end

		def self.create_xlsx_file(vk_contacts, opts = {})
			VkConctactsXSLXFileCreator.new(vk_contacts).create(opts)
		end
	end

	class SaveVkContactsSource
		attr_reader :vk_c_source_name, :vk_c_source_identifier, :total_count, :opts

		def initialize(vk_c_source_name, vk_c_source_identifier, total_count, opts = {})
			@vk_c_source_name = vk_c_source_name
			@vk_c_source_identifier = vk_c_source_identifier
			@total_count = total_count
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
					VkContactsSource.create!(name: vk_c_source_name, vk_identifier: vk_c_source_identifier, total_count: total_count)
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
			[
				_save_vk_contacts_skype_vcf,
				_save_vk_contacts_xlsx_file
			]
		end

		def _save_vk_contacts_skype_vcf
			vk_contacts_file_path = VkContactsFileCreator.create_skype_vcf(
				vk_contacts_filtered,
				filename_prefix: vk_c_source.name
			)
			_open_file(vk_contacts_file_path) do |file|
				_save_vk_contacts_file("#{vk_c_source.name}_vcf", file, vk_c_source.id)
			end
		end

		def _save_vk_contacts_xlsx_file
			vk_contacts_file_path = VkContactsFileCreator.create_xlsx_file(
				vk_contacts_filtered,
				prefix: vk_c_source.name
			)
			_open_file(vk_contacts_file_path) do |file|
				_save_vk_contacts_file("#{vk_c_source.name}_xlsx", file, vk_c_source.id)
			end
		end

		def _open_file(file_path)
			file_io = File.open(file_path, 'r')
			res = yield(file_io)
			file_io.close
			File.delete(file_path)
			res
		end

		def _save_vk_contacts_file(name, file, vk_contacts_source_id)
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

	# class VkContactsSorter
	# 	def _sort_vk_contacts_filtered
	# 		vk_contacts_filtered.inject({ skype: [], phone: [], instagram: [], twitter: [] }) do |_hash, _vk_contact|
	# 			_vk_contact = Hashie::Mash.new(_vk_contact)
	# 			_hash.merge({
	# 					skype: _vk_contact.skype.nil? ? _hash[:skype] << _vk_contact.skype : _hash[:skype],
	# 					phone: _vk_contact.mobile_phone.nil? ? _hash[:phone] << _vk_contact.mobile_phone : _hash[:phone],
	# 					instagram: _vk_contact.instagram.nil? ? _hash[:instagram] << _vk_contact.instagram : _hash[:instagram],
	# 					twitter: _vk_contact.twitter.nil? ? _hash[:twitter] << _vk_contact.twitter : _hash[:twitter]
	# 				})
	# 		end
	# 	end
	# end

	class VkContactsSorter
		class << self
			def remove_useless(contacts)
				new.remove_useless(contacts)
			end

			def rearrange_by_type(contacts)
				new.rearrange_by_type(contacts)
			end
		end

		def remove_useless(contacts)
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

		def rearrange_by_type(contacts)
			contacts.inject({ skype: [], phone: [], instagram: [], twitter: [] }) do |_hash, _vk_contact|
				_vk_contact = Hashie::Mash.new(_vk_contact)
				_hash.merge({
						skype: _vk_contact.skype.nil? ? _hash[:skype] << _vk_contact.skype : _hash[:skype],
						phone: _vk_contact.mobile_phone.nil? ? _hash[:phone] << _vk_contact.mobile_phone : _hash[:phone],
						instagram: _vk_contact.instagram.nil? ? _hash[:instagram] << _vk_contact.instagram : _hash[:instagram],
						twitter: _vk_contact.twitter.nil? ? _hash[:twitter] << _vk_contact.twitter : _hash[:twitter]
					})
			end
		end

		private

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
		unless (user = User.find(user_id)).nil?
			if (vk_contacts_parsed = _parse_contacts(vk_contacts_json)).size <= 100000 or user.is_admin?
				vk_contacts_filtered = _remove_useless_contacts(vk_contacts_parsed)
				vk_c_source = _save_vk_contacts_source(vk_c_source_name, vk_c_source_identifier, vk_contacts_filtered.size)
				vk_c_files = _save_vk_contacts_files(vk_contacts_filtered, vk_c_source)
				_link_user_with_vk_c_files(user, vk_c_files)
			end
		end
	end

	private

	def _parse_contacts(*args)
		MultiJson.load(*args)
	end

	def _remove_useless_contacts(*args)
		VkContactsSorter.remove_useless(*args)
	end

	def _rearrange_contacts_by_type(*args)
		VkContactsSorter.rearrange_by_type(*args)
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