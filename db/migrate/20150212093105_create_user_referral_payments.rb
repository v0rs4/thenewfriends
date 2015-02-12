class CreateUserReferralPayments < ActiveRecord::Migration
	def up
		create_table :user_referral_payments do |t|
			t.integer :user_id, null: false
			t.float :amount, null: false

			t.timestamps
		end
	end

	def down
		drop_table :user_referral_payments
	end
end
