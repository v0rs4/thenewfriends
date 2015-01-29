class Admin::ApplicationController < ApplicationController
	before_action :authorize_user_as_admin!

	protected

	def authorize_user_as_admin!
		raise ActionController::RoutingError.new('Not Found') unless current_user.is_admin?
	end
end