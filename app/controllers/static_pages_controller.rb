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
			redirect_uri: work_vk_o_auth_authorize_url,
			v: '5.24',
			response_type: :code
		}.map { |k, v| "#{k}=#{v}" }.join('&')
		@vk_oauth_url = "#{vk_oauth_host}?#{vk_oauth_params}"
		@user_vk_contacts_files = current_user.decorate.last_n_vk_contacts_files(10)
	end

	def pricing_plans
		@pricing_plan_sci = {
			vk_contacts_collector: generate_pricing_plan_pm_sci('vk_contacts_collector', 15)
		}
	end

	def pmvf

	end

	def referrals

	end

	private

	def generate_pricing_plan_pm_sci(name, price)
		PerfectMoneyMerchant::SCI.new(
			price: price,
			payee: PerfectMoneyMerchant::Account.obtain_deposit_account(:usd),
			additional: {
				user_id: current_user.id,
				pricing_plan_name: name,
				pricing_plan_price: price
			},
			verification: [:user_id, :pricing_plan_name, :pricing_plan_price],
			purpose: 'pricing_plan',
			redirect_url: work_pricing_plans_url
		)
	end
end