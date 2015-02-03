class TnfLandingPageController < ApplicationController
	skip_before_action :authenticate_user!

	layout 'tnf_landing_page'

	def index

	end
end