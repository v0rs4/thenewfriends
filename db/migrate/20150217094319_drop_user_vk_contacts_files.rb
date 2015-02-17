class DropUserVkContactsFiles < ActiveRecord::Migration
	def change
		drop_table :user_vk_contacts_files
	end
end
