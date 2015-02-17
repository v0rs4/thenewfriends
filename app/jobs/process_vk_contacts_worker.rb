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

	class SaveUserVkContactsRecord
		def self.run(user, name, vk_contacts_filtered, vk_source_identifier, opts = {})
			new.run(user, name, vk_contacts_filtered, vk_source_identifier, opts = {})
		end

		def run(user, name, vk_contacts_filtered, vk_source_identifier, opts = {})
			vcf_file_path = VkContactsFileCreator.create_skype_vcf(
				vk_contacts_filtered,
				filename_prefix: name
			)
			xlsx_file_path = VkContactsFileCreator.create_xlsx_file(
				vk_contacts_filtered,
				prefix: name
			)

			vk_contacts_rearranged = VkContactsSorter.rearrange_by_type(vk_contacts_filtered)

			_open_file(vcf_file_path) do |_vcf_file|
				_open_file(xlsx_file_path) do |_xlsx_file|
					unless UserVkContactsRecord.exists?(user_id: user.id, name: name, vk_source_identifier: vk_source_identifier)
						UserVkContactsRecord.create(
							user_id: user.id,
							name: name,
							vcf_file: _vcf_file,
							xlsx_file: _xlsx_file,
							vk_source_identifier: vk_source_identifier,
							skype_count: vk_contacts_rearranged[:skype].size,
							instagram_count: vk_contacts_rearranged[:instagram].size,
							twitter_count: vk_contacts_rearranged[:twitter].size,
							phone_count: vk_contacts_rearranged[:phone].size,
							total_count: vk_contacts_filtered.size,
						)
					end
				end
			end
		end

		private

		def _open_file(file_path)
			file_io = File.open(file_path, 'r')
			res = yield(file_io)
			file_io.close
			File.delete(file_path)
			res
		end
	end

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

				phones = []
				phones << _vk_contact.mobile_phone unless _vk_contact.mobile_phone.nil?
				phones << _vk_contact.home_phone unless _vk_contact.home_phone.nil?

				_hash.merge({
						skype: _vk_contact.skype.nil? ? _hash[:skype] : _hash[:skype] << _vk_contact.skype,
						phone: _hash[:phone] += phones,
						instagram: _vk_contact.instagram.nil? ? _hash[:instagram] : _hash[:instagram] << _vk_contact.instagram,
						twitter: _vk_contact.twitter.nil? ? _hash[:twitter] : _hash[:twitter] << _vk_contact.twitter
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

	def perform(vk_c_record_name, vk_source_identifier, vk_contacts_json, user_id)
		unless (user = User.find(user_id)).nil?
			vk_contacts_parsed = MultiJson.load(vk_contacts_json)
			vk_contacts_filtered = VkContactsSorter.remove_useless(vk_contacts_parsed)
			SaveUserVkContactsRecord.run(user, vk_c_record_name, vk_contacts_filtered, vk_source_identifier)
		end
	end
end