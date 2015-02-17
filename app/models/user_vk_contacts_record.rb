class UserVkContactsRecord < ActiveRecord::Base
	belongs_to :user, inverse_of: :user_vk_contacts_records

	# scope :unarchived, -> { where(archived: false) }
	# scope :archived, -> { where(archived: true) }

	scope :created_today, -> { where("created_at >= ?", Time.zone.now.beginning_of_day) }

	mount_uploader :xlsx_file, VkContactsFileUploader
	mount_uploader :vcf_file, VkContactsFileUploader

	def created_today?
		created_at >= Time.zone.now.beginning_of_day
	end
end
