class AddReferralAwardLevelsToUsers < ActiveRecord::Migration
	def up
		add_column :users, :referral_award_level_1, :float, default: 0, null: false
		add_column :users, :referral_award_level_2, :float, default: 0, null: false
	end

	def down
		remove_column :users, :referral_award_level_1
		remove_column :users, :referral_award_level_2
	end
end
