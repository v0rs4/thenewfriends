PerfectMoneyMerchant::Configuration.configure do |config|
	config.verification_secret = 'qwLhDQlEQA5gy0cAnd7jm5TTzDE8MImEMV1A58om'

	config.payee_name = 'The New Friends'
	config.suggested_memo = 'The New Friends Payment'

	config.add_task :pricing_plan, ->(params) {
		unless (user = User.find_by_id(params[:user_id])).nil?
			case params[:pricing_plan_name]
			when 'vk_contacts_collector'
				UserReferralManager.new(user.inviter).earn unless user.inviter.nil?

				user.user_permission.update_attributes(
					user_vk_contacts_files_create: true,
					user_vk_contacts_files_read: true,
					user_vk_contacts_files_update: true
				)
			else
				# nothing
			end
		end
	}
end