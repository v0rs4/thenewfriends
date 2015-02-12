PerfectMoneyMerchant::Configuration.configure do |config|
	config.verification_secret = 'qwLhDQlEQA5gy0cAnd7jm5TTzDE8MImEMV1A58om'

	config.payee_name = 'The New Friends'
	config.suggested_memo = 'The New Friends Payment'

	config.add_task :pricing_plan, ->(params, _) {
		unless (user = User.find_by_id(params[:user_id])).nil?
			if params[:payment_amount].try(:to_f) == params[:pricing_plan_price].try(:to_f)
				if params[:pricing_plan_name] =~ /\A([A-z]+)_(\d{2,3})\z/
					UserPurchaseManager.new(user).buy_vk_contacts_collector(params[:pricing_plan_name])
				end
			end
		end
	}
end