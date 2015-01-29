class UserVkContactsFilesController < ApplicationController
	def index
		user_vk_contacts_files_rel = current_user.user_vk_contacts_files.order('created_at DESC')
		case params[:scope]
		when 'all'
			@user_vk_contacts_files = user_vk_contacts_files_rel
		when 'archived'
			@user_vk_contacts_files = user_vk_contacts_files_rel.archived
		else
			@user_vk_contacts_files = user_vk_contacts_files_rel.unarchived
		end
	end

	def show

	end

	def edit

	end

	def update
		@user_vk_contacts_file = UserVkContactsFile.find(params[:id])
		respond_to do |format|
			if @user_vk_contacts_file.update_attributes(update_params)
				format.html do
					if params[:redirect_to]
						redirect_to params[:redirect_to], notice: 'Sucsess'
					else
						redirect_to :back, notice: 'Sucsess'
					end

				end
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @user_vk_contacts_file.errors, status: :unprocessable_entity }
			end
		end
	end

	def download
		vk_contacts_file_url = UserVkContactsFile.find(params[:id]).vk_contacts_file.file.url
		if vk_contacts_file_url =~ /http/
			redirect_to vk_contacts_file_url
		else
			redirect_to :back
		end
	end

	private

	def update_params
		params.require(:user_vk_contacts_file).permit(:archived)
	end
end