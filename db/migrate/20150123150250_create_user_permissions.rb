class CreateUserPermissions < ActiveRecord::Migration
	def up
		create_table :user_permissions do |t|
			t.integer :user_id, null: false
			t.boolean :user_vk_contacts_files_create, null: false, default: false
			t.boolean :user_vk_contacts_files_read, null: false, default: false
			t.boolean :user_vk_contacts_files_update, null: false, default: false
			t.boolean :user_vk_contacts_files_delete, null: false, default: false
			t.timestamps
		end
	end

	def down
		drop_table :user_permissions
	end
end
