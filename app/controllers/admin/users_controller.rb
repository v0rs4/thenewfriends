class Admin::UsersController < Admin::ApplicationController
	def index
		@users = User.all.order('created_at DESC')
	end

	def edit
		@user = User.find(params[:id])
	end

	def show
		@user = User.find(params[:id])
	end

	def update
		@user = User.find(params[:id])
		respond_to do |format|
			if @user.update(update_params)
				format.html { redirect_to work_admin_user_path(@user), notice: 'User was successfully updated.' }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @user.errors, status: :unprocessable_entity }
			end
		end
	end

	def update_params
		params.require(:user).permit(
			:email,
			:is_admin,
			:referral_earned,
			:referral_award_level_1,
			:referral_award_level_2,
			:inviter_id,
			user_vk_contacts_collector_permission_attributes: [
				:id,
				:package,
				:expires_at,
				:requests_limit_per_day,
				:can_create,
				:can_read,
				:can_update,
				:can_delete
			],
			# user_permission_attributes: [
			# 	:id,
			# 	:user_vk_contacts_files_create,
			# 	:user_vk_contacts_files_read,
			# 	:user_vk_contacts_files_update,
			# 	:user_vk_contacts_files_delete,
			# 	:user_vk_contacts_files_create_expires_at,
			# 	:user_vk_contacts_files_read_expires_at,
			# 	:user_vk_contacts_files_update_expires_at,
			# 	:user_vk_contacts_files_delete_expires_at,
			# 	:vk_contacts_requests_limit_per_day
			# ],
			user_profile_attributes: [
				:id,
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
		)
	end
end