class Admin::StaticPagesController < Admin::ApplicationController
	def dashboard
		@pending_pay_out = (User.sum(:referral_earned) - User.sum(:referral_paid_out)).round(2)
		@total_usd_amount = PerfectMoneyMerchant::Account::Unit.where(currency: :usd).sum(:balance)
		@total_users_count = User.count
		@total_user_vk_contacts_records_count = UserVkContactsRecord.count
	end
end