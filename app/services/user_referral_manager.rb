class UserReferralManager
	attr_reader :user

	def initialize(user)
		@user = user
	end

	def earn
		if user.referral_award > 0
			user.update_attributes(referral_earned: (user.referral_earned + user.referral_award).round(2))
		else
			false
		end
	end

	def pay_out(amount)
		user.with_lock do
			if user.decorate.referral_balance >= amount
				PerfectMoneyMerchant::Account.transfer!(user.user_profile.pm_usd_acct, amount)
				user.update_attributes(referral_paid_out: (user.referral_paid_out + amount).round(2))
				true
			else
				false
			end
		end
	end
end