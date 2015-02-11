class DropUserPermissions < ActiveRecord::Migration
	def change
		drop_table :user_permissions
	end
end
