class DropVkContactsSources < ActiveRecord::Migration
	def change
		drop_table :vk_contacts_sources
	end
end
