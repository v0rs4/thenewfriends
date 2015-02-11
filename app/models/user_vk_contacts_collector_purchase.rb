class UserVkContactsCollectorPurchase < UserPurchase
	# after_commit :calculate_user_inviter_referral_awards
	#
	# def calculate_user_inviter_referral_awards
	# 	unless user.nil? and user.inviter.nil?
	# 		UserReferralManager.new(user.inviter).calculate_referral_awards
	# 	end
	# end
end