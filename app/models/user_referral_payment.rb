class UserReferralPayment < ActiveRecord::Base
	belongs_to :user, inverse_of: :user_referral_payments
end
