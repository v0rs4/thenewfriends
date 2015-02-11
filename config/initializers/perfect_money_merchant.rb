PerfectMoneyMerchant::Configuration.configure do |config|
	config.verification_secret = 'qwLhDQlEQA5gy0cAnd7jm5TTzDE8MImEMV1A58om'

	config.payee_name = 'The New Friends'
	config.suggested_memo = 'The New Friends Payment'

	config.add_task :pricing_plan, ->(params, pm_payment_id) {
		unless (user = User.find_by_id(params[:user_id])).nil?
			if params[:payment_amount].try(:to_f) == params[:pricing_plan_price].try(:to_f)
				if params[:pricing_plan_name] =~ /\A([A-z]+)_(\d{2,3})\z/
					ActiveRecord::Base.transaction do
						UserPermissionManager.new(user).permit(:vk_contacts_collector,
							package_name: params[:pricing_plan_name]
						)

						UserReferralManager.new(user).pay_the_inviter(params[:payment_amount].to_f)

						UserVkContactsCollectorPurchase.create!(
							user_id: user.id,
							name: params[:pricing_plan_name],
							perfect_money_payment_id: pm_payment_id
						)

						unless user.inviter.nil?
							UserReferralManager.new(user.inviter).calculate_referral_awards
						end
					end
				end
			end
		end
	}
end