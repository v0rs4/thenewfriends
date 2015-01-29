class CreateVkContactsSources < ActiveRecord::Migration
	def up
		create_table :vk_contacts_sources do |t|
			t.string :name, null: false
			t.string :vk_identifier, null: false
			t.timestamps
		end

		add_index :vk_contacts_sources, :vk_identifier, unique: true, name: :vk_c_sources_vk_identifier_unq
	end

	def down
		drop_table :vk_contacts_sources
		remove_index :vk_contacts_sources, name: :vk_c_sources_vk_identifier_unq
	end
end
