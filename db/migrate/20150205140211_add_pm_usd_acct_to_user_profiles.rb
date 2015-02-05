class AddPmUsdAcctToUserProfiles < ActiveRecord::Migration
	def up
		add_column :user_profiles, :pm_usd_acct, :string
	end

	def down
		remove_column :user_profiles, :pm_usd_acct
	end
end
