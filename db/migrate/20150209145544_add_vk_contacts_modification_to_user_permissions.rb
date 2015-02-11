class AddVkContactsModificationToUserPermissions < ActiveRecord::Migration
	def up
		add_column :user_permissions, :user_vk_contacts_files_create_expires_at, :datetime
		add_column :user_permissions, :user_vk_contacts_files_read_expires_at, :datetime
		add_column :user_permissions, :user_vk_contacts_files_update_expires_at, :datetime
		add_column :user_permissions, :user_vk_contacts_files_delete_expires_at, :datetime
		add_column :user_permissions, :vk_contacts_requests_limit_per_day, :integer, default: 0, null: false
	end

	def down
		remove_column :user_permissions, :user_vk_contacts_files_create_expires_at
		remove_column :user_permissions, :user_vk_contacts_files_read_expires_at
		remove_column :user_permissions, :user_vk_contacts_files_update_expires_at
		remove_column :user_permissions, :user_vk_contacts_files_delete_expires_at
		remove_column :user_permissions, :vk_contacts_requests_limit_per_day
	end
end
