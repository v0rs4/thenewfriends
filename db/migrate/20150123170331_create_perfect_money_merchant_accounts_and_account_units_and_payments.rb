class CreatePerfectMoneyMerchantAccountsAndAccountUnitsAndPayments < ActiveRecord::Migration
	def up
		create_table :perfect_money_merchant_accounts do |t|
			t.string :login
			t.string :password
			t.string :secret_key
		end

		create_table :perfect_money_merchant_account_units do |t|
			t.integer :account_id
			t.string :currency
			t.string :code_number
			t.float :balance
		end

		create_table :perfect_money_merchant_payments do |t|
			t.string :payment_batch_num
			t.string :payment_id
			t.string :payment_amount
			t.string :payer_account
			t.string :payee_account
			t.timestamps
		end


		add_index :perfect_money_merchant_payments, :payment_batch_num, :unique => true, name: :pmmp_pbn_unq
		add_index :perfect_money_merchant_accounts, :login, :unique => true, name: :pmma_l_unq
		add_index :perfect_money_merchant_accounts, :secret_key, :unique => true, name: :pmma_sk_unq
		add_index :perfect_money_merchant_account_units, :code_number, :unique => true, name: :pmmam_cn_unq
	end

	def down
		drop_table :perfect_money_merchant_accounts  
		drop_table :perfect_money_merchant_account_units 
		drop_table :perfect_money_merchant_payments

		remove_index :perfect_money_merchant_payments, name: :pmmp_pbn_unq
		remove_index :perfect_money_merchant_accounts, name: :pmma_l_unq
		remove_index :perfect_money_merchant_accounts, name: :pmma_sk_unq
		remove_index :perfect_money_merchant_account_units, name: :pmmam_cn_unq
	end
end