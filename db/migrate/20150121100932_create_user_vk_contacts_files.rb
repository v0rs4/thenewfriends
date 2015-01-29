class CreateUserVkContactsFiles < ActiveRecord::Migration
	def up
		create_table :user_vk_contacts_files do |t|
			t.integer :user_id, null: false
			t.integer :vk_contacts_file_id, null: false
			t.boolean :archived, null: false, default: false
			t.timestamps
		end

		add_index :user_vk_contacts_files, [:user_id, :vk_contacts_file_id], unique: true, name: :user_vk_c_files_u_id_vk_c_f_id_unq
	end

	def down
		drop_table :user_vk_contacts_files
		remove_index :user_vk_contacts_files, name: :user_vk_c_files_u_id_vk_c_f_id_unq
	end
end
