# == Schema Information
#
# Table name: vk_contacts_files
#
#  id                               :integer            not null, primary key
#  name                             :string             not null
#  vk_contacts_source_id            :integer            not null
#  file                             :string             not null
#
# Indexes
# vk_c_files_name_v_c_source_id_unq             (name, vk_contacts_source_id)         UNIQUE
#
class VkContactsFile < ActiveRecord::Base
	belongs_to :vk_contacts_source
	has_many :user_vk_contacts_file, dependent: :destroy
	mount_uploader :file, VkContactsFileUploader
end