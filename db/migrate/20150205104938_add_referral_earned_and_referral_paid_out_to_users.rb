class AddReferralEarnedAndReferralPaidOutToUsers < ActiveRecord::Migration
	def up
		add_column :users, :referral_earned, :float, default: 0, null: false
		add_column :users, :referral_paid_out, :float, default: 0, null: false
	end

	def down
		remove_column :users, :referral_earned
		remove_column :users, :referral_paid_out
	end
end
