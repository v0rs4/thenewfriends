class UserPurchase < ActiveRecord::Base
	belongs_to :user, inverse_of: :user_purchases
	belongs_to :perfect_money_payment, class_name: 'PerfectMoneyMerchant::Payment', foreign_key: :perfect_money_payment_id
end
