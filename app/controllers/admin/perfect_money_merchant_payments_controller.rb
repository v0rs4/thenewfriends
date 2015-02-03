class Admin::PerfectMoneyMerchantPaymentsController < Admin::ApplicationController
	def index
		@payments = PerfectMoneyMerchant::Payment.all
	end
end