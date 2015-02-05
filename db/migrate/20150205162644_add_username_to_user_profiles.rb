class AddUsernameToUserProfiles < ActiveRecord::Migration
	def up
		add_column :user_profiles, :username, :string
	end

	def down
		remove_column :user_profiles, :username
	end
end
