class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	layout :layout_by_resource
	# noinspection RailsParamDefResolve
	before_action :authenticate_user!
	# noinspection RailsParamDefResolve
	before_action :set_current_user, if: :user_signed_in?
	before_action :set_app_version
	# noinspection RailsParamDefResolve
	before_action :configure_devise_permitted_parameters, if: :devise_controller?

	before_action :set_locale
	before_action :set_referral

	after_filter :set_csrf_cookie_for_ng

	def set_csrf_cookie_for_ng
		cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
	end

	protected

	# In Rails 4.1 and below
	def verified_request?
		super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
	end

	def layout_by_resource
		if devise_controller?
			"devise"
		else
			"application"
		end
	end

	def set_current_user
		@current_user = current_user
		@current_user_d = current_user.decorate

		if current_user.is_admin?
			cookies[:is_admin] = true
		else
			cookies.delete(:is_admin) if cookies[:is_admin]
		end
	end

	def set_app_version
		@version = TheNewFriends::VERSION
	end

	def set_referral
		if params[:ref]
			cookies[:ref] = { domain: :all, value: params[:ref], expires: 365.days.from_now }
		end
	end

	def set_locale
		if params[:locale]
			if I18n.available_locales.map(&:to_s).include?(params[:locale])
				cookies[:locale] = { value: params[:locale], expires: 365.days.from_now }
			end
		end
		I18n.locale = cookies[:locale] || I18n.default_locale
	end

	def configure_devise_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) << :invite_code
	end
end
