class AddInviterIdToUsers < ActiveRecord::Migration
	def up
		add_column :users, :inviter_id, :integer
	end

	def down
		remove_column :users, :inviter_id
	end
end
