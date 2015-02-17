class DropVkContactsFiles < ActiveRecord::Migration
	def change
		drop_table :vk_contacts_files
	end
end
