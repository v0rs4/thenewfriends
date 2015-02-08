class TnfLandingPageController < ApplicationController
	skip_before_action :authenticate_user!

	layout 'tnf_landing_page'

	def index
		if cookies[:ref].nil?
			@referral = User.where(is_admin: true).take(1).first
		else
			if (@referral = UserProfile.find_by_username(cookies[:ref]).try(:user)).nil?
				@referral = User.where(is_admin: true).take(1).first
			end
		end
	end
end