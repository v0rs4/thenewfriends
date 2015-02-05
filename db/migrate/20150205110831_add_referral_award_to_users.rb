class AddReferralAwardToUsers < ActiveRecord::Migration
	def up
		add_column :users, :referral_award, :float, default: 0, null: false
	end

	def down
		remove_column :users, :referral_award
	end
end
