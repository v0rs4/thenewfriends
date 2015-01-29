class StaticPagesController < ApplicationController
	def dashboard
	end

	def vkontakte_contacts_collector
		vk_oauth_host = 'https://oauth.vk.com/authorize'
		vk_oauth_params = {
			client_id: 4523313,
			scope: [
				:friends,
				:groups,
				:offline
			].join(','),
			redirect_uri: vk_o_auth_authorize_url,
			v: '5.24',
			response_type: :code
		}.map { |k, v| "#{k}=#{v}" }.join('&')
		@vk_oauth_url = "#{vk_oauth_host}?#{vk_oauth_params}"
		@user_vk_contacts_files = current_user.decorate.last_n_vk_contacts_files(10)
	end

	def pricing_plans
		@pricing_plan_sci = {
			vk_contacts_collector: generate_pricing_plan_pm_sci('vk_contacts_collector', 20)
		}
	end

	private

	def generate_pricing_plan_pm_sci(price, name)
		PerfectMoneyMerchant::SCI.new(
			price: '20',
			payee: PerfectMoneyMerchant::Account.obtain_deposit_account(:usd),
			additional: {
				user_id: current_user.id,
				pricing_plan_name: 'vk_contacts_collector',
				pricing_plan_price: '20'
			},
			verification: [:user_id, :pricing_plan_name, :pricing_plan_price],
			purpose: 'pricing_plan'
		)
	end
end