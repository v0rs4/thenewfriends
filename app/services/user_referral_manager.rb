class UserReferralManager
	attr_reader :user

	class CalculateReferralAwards
		attr_reader :user

		def initialize(user)
			@user = user
		end

		def run
			if can_up_to_45_30?
				up_to_45_30
			elsif can_up_to_30_20?
				up_to_30_20
			else
				up_to_15_0
			end
		end

		private

		def can_up_to_45_30?
			user.has_purchase?([:seasoned_240, :advanced_360], :vk_contacts_collector) and
				user.get_referrals_by(vk_contacts_collector: { package_name: :seasoned_240_or_greater }).count > 5
		end

		def can_up_to_30_20?
			user.has_purchase?([:skilled_120, :seasoned_240, :advanced_360], :vk_contacts_collector) and
				user.get_referrals_by(vk_contacts_collector: { package_name: :skilled_120_or_greater }).count > 5
		end

		def up_to_45_30
			user.referral_award_level_1 = 45 if user.referral_award_level_1 < 45
			user.referral_award_level_2 = 30 if user.referral_award_level_2 < 30
			user.save if user.changed?
		end

		def up_to_30_20
			user.referral_award_level_1 = 30 if user.referral_award_level_1 < 30
			user.referral_award_level_2 = 20 if user.referral_award_level_2 < 20
			user.save if user.changed?
		end

		def up_to_15_0
			user.referral_award_level_1 = 15 unless user.referral_award_level_1 == 15
			user.referral_award_level_2 = 0 unless user.referral_award_level_2 == 0
			user.save if user.changed?
		end
	end

	def initialize(user)
		@user = user
	end

	def earn(earned_amount)
		# if user.referral_award_level(level) > 0
		# 	user.update_attributes(referral_earned: (user.referral_earned + user.referral_award_level(level)).round(2))
		# else
		# 	false
		# end
		if earned_amount > 0
			user.update_attributes(referral_earned: (user.referral_earned + earned_amount).round(2))
		else
			false
		end
	end

	def pay_out(amount_to_pay_out)
		user.with_lock do
			if user.decorate.referral_balance >= amount_to_pay_out
				PerfectMoneyMerchant::Account.transfer!(user.user_profile.pm_usd_acct, amount_to_pay_out)
				user.update_attributes(referral_paid_out: (user.referral_paid_out + amount_to_pay_out).round(2))
				true
			else
				false
			end
		end
	end

	def calculate_referral_awards
		CalculateReferralAwards.new(user).run
	end

	def pay_the_inviter(income_amount)
		user_to_pay = user.inviter
		total_percent = 0

		1.upto(2) do |level|
			if user_to_pay.nil?
				break
			else
				user_to_pay_percent = user_to_pay.referral_award_level(level)
				UserReferralManager.new(user_to_pay).earn(income_amount * user_to_pay_percent/100)
				total_percent += user_to_pay_percent
				user_to_pay = user_to_pay.inviter
			end
		end

		admins = User.where(is_admin: true)
		if admins.size > 0
			admins.each do |admin|
				UserReferralManager.new(admin).earn(income_amount * (100 - total_percent)/admins.size/100)
			end
		end

		true
	end
end