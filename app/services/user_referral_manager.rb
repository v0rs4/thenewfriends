class UserReferralManager
	attr_reader :user

	def initialize(user)
		@user = user
	end

	def earn(level)
		if user.referral_award_level(level) > 0
			user.update_attributes(referral_earned: (user.referral_earned + user.referral_award_level(level)).round(2))
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

	def self.pay_the_inviter(user)
		user_to_pay = user.inviter

		1.upto(2) do |level|
			if user_to_pay.nil?
				break
			else
				new(user_to_pay).earn(level)
				user_to_pay = user_to_pay.inviter
			end
		end
	end
end