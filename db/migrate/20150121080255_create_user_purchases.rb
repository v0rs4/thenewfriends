class CreateUserPurchases < ActiveRecord::Migration
	def up
		create_table :user_purchases do |t|
			t.integer :user_id, null: false
			t.string :name, null: false

			t.timestamps
		end

		add_index :user_purchases, [:user_id, :name], unique: true, name: :user_purchases_user_id_name_unq
	end

	def down
		drop_table :user_purchases
		remove_index :user_purchases, name: :user_purchases_user_id_name_unq
	end
end
