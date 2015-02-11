class CreateUserVkContactsCollectorPermissions < ActiveRecord::Migration
	def up
		create_table :user_vk_contacts_collector_permissions do |t|
			t.integer :user_id, null: false
			t.string :package
			t.datetime :expires_at
			t.boolean :can_create, default: false, null: false
			t.boolean :can_read, default: false, null: false
			t.boolean :can_update, default: false, null: false
			t.boolean :can_delete, default: false, null: false

			t.timestamps
		end
	end

	def down
		drop_table :user_vk_contacts_collector_permissions
	end
end
