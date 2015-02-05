class UserProfilesController < ApplicationController
	def edit
		@user_profile = current_user.user_profile
	end

	def update
		@user_profile = current_user.user_profile
		respond_to do |format|
			if @user_profile.update_attributes(update_params)
				format.html do
					redirect_to :work_root, notice: 'Your profile was successfully updated.'
				end
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @user_profile.errors, status: :unprocessable_entity }
			end
		end
	end

	private

	def update_params
		_permitted_params = [
			:first_name,
			:last_name,
			:about,
			:country,
			:city,
			:skype,
			:contact_phone,
			:contact_email,
			:vkontakte_id,
			:facebook_id,
			:twitter_id,
			:pm_usd_acct,
			:username
		]
		params.require(:user_profile).permit(*_permitted_params)
	end
end