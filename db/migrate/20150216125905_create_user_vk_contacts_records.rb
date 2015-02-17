class CreateUserVkContactsRecords < ActiveRecord::Migration
	def up
		create_table :user_vk_contacts_records do |t|
			t.integer :user_id
			t.string :name
			t.string :vcf_file
			t.string :xlsx_file
			t.string :vk_source_identifier
			t.integer :skype_count
			t.integer :instagram_count
			t.integer :twitter_count
			t.integer :phone_count
			t.integer :total_count
			t.timestamps
		end

		add_index :user_vk_contacts_records, [:user_id, :name, :vk_source_identifier], unique: true, name: :uvcr_ui_n_vsi_u
	end

	def down
		drop_table :user_vk_contacts_records
		remove_index :user_vk_contacts_records, column: [:user_id, :name, :vk_source_identifier]
	end
end
