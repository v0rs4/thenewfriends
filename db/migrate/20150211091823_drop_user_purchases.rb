class DropUserPurchases < ActiveRecord::Migration
	def change
		drop_table :user_purchases
	end
end
