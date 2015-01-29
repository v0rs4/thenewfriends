class UserPurchase < ActiveRecord::Base
	belongs_to :user, inverse_of: :user_purchases
end
