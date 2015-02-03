class VkOAuthController < ApplicationController
	def authorize
		vk_oauth_result = vk_oauth_connection.get('access_token',
			{
				client_id: '4523313',
				client_secret: 'qlBtRMtbAyvfzvBy4kuh',
				code: params[:code],
				redirect_uri: work_vk_o_auth_authorize_url
			}
		)

		cookies[:vk_access_token] = vk_oauth_result.body['access_token']

		if params[:redirect_to]
			redirect_to params[:redirect_to]
		else
			redirect_to work_vkontakte_contacts_collector_path
		end
	end

	def logout
		cookies.delete(:vk_access_token)
		redirect_to :back, notice: 'You have logged out successfully'
	end

	private

	def http_connection(endpoint)
		Faraday.new(url: endpoint) do |faraday|
			faraday.request :url_encoded
			faraday.response :json, :content_type => /\bjson$/
			faraday.adapter Faraday.default_adapter
		end
	end

	def vk_oauth_connection
		@vk_oauth_connection ||= http_connection('https://oauth.vk.com')
	end
end