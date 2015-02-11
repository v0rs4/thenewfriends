class UserVkContactsFile < ActiveRecord::Base
	belongs_to :user, inverse_of: :user_vk_contacts_files
	belongs_to :vk_contacts_file

	scope :unarchived, -> { where(archived: false) }
	scope :archived, -> { where(archived: true) }
	scope :vk_contacts_file_included, -> { joins(:vk_contacts_file).includes(:vk_contacts_file) }
	scope :created_today, -> { where("created_at >= ?", Time.zone.now.beginning_of_day) }
end
