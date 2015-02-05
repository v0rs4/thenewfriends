class UsersController < ApplicationController
	def pay_out
		respond_to do |format|
			if UserReferralManager.new(current_user).pay_out(current_user.decorate.referral_balance)
				format.html { redirect_to :back }
				format.json { head :no_content }
			else
				format.html { redirect_to :back }
				format.json { head :no_content }
			end
		end
	end
end