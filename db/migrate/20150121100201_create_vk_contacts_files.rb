class CreateVkContactsFiles < ActiveRecord::Migration
	def up
		create_table :vk_contacts_files do |t|
			t.string :name, null: false
			t.string :file, null: false
			t.integer :vk_contacts_source_id, null: false
			t.timestamps
		end

		add_index :vk_contacts_files, [:name, :vk_contacts_source_id], unique: true, name: :vk_c_files_name_v_c_source_id_unq
	end

	def down
		drop_table :vk_contacts_files
		remove_index :vk_contacts_files, name: :vk_c_files_name_v_c_source_id_unq
	end
end
