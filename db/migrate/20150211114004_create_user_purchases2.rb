class CreateUserPurchases2 < ActiveRecord::Migration
	def up
		create_table :user_purchases do |t|
			t.integer :user_id, null: false
			t.string :name, null: false
			t.string :type, null: false
			t.integer :perfect_money_payment_id

			t.timestamps
		end
	end

	def down
		drop_table :user_purchases
	end
end
