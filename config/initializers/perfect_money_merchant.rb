PerfectMoneyMerchant::Configuration.configure do |config|
	config.verification_secret = 'qwLhDQlEQA5gy0cAnd7jm5TTzDE8MImEMV1A58om'

	config.payee_name = 'The New Friends'
	config.suggested_memo = 'The New Friends Payment'

	config.add_task :pricing_plan, ->(params) {
		unless (user = User.find_by_id(params[:user_id])).nil?
			case params[:pricing_plan_name]
			when 'vk_contacts_collector'
				UserReferralManager.pay_the_inviter(user)
				UserPermissionManager.new(user).permit(:vk_contacts_collector)
			else
				# nothing
			end
		end
	}
end