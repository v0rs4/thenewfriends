class AddTotalCountToVkContactsSources < ActiveRecord::Migration
	def up
		add_column :vk_contacts_sources, :total_count, :integer, default: 0, null: false
	end

	def down
		remove_column :vk_contacts_sources, :total_count, :integer, default: 0, null: false
	end
end
