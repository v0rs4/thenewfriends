class VkContactsSource < ActiveRecord::Base
	has_many :vk_contacts_files, dependent: :destroy
	validates :vk_identifier, uniqueness: true
end