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
			newbie_30: generate_pricing_plan_pm_sci('newbie_30', 10.0),
			novice_60: generate_pricing_plan_pm_sci('novice_60', 15.0),
			skilled_120: generate_pricing_plan_pm_sci('skilled_120', 25.0),
			seasoned_240: generate_pricing_plan_pm_sci('seasoned_240', 45.0),
			advanced_360: generate_pricing_plan_pm_sci('advanced_360', 80.0)
		}
		unless @current_user.vcc_permission.package.blank?
			@pricing_plan_sci.delete_if do |name, sci|
				UserVkContactsCollectorPermission.get_package_by(:name, name)[:level] <= UserVkContactsCollectorPermission.get_package_by(:name, @current_user.vcc_permission.package.to_sym)[:level]
			end
		end
	end

	def pmvf

	end

	def referrals

	end

	def faq

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