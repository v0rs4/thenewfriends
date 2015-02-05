class UserReferralManager
	attr_reader :user

	def initialize(user)
		@user = user
	end

	def earn
		user.update_attributes(referral_earned: (user.referral_earned + user.referral_award).round(2))
	end
end