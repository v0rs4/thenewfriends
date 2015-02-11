class AddRequestsLimitPerDayToVkContactsCollectorPermissions < ActiveRecord::Migration
	def up
		add_column :user_vk_contacts_collector_permissions, :requests_limit_per_day, :integer, default: 0, null: false
	end

	def down
		remove_column :user_vk_contacts_collector_permissions, :requests_limit_per_day
	end
end
