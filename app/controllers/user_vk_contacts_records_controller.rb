class UserVkContactsRecordsController < ApplicationController
	def index
		@user_vk_contacts_records = current_user.user_vk_contacts_records.order('created_at DESC')
	end

	def download
		resource = UserVkContactsRecord.find(params[:id])
		case params[:target].to_sym
		when :vcf
			redirect_to resource.vcf_file.url
		when :xlsx
			redirect_to resource.xlsx_file.url
		else
			redirect_to :back
		end
	end

	def destroy
		resource = UserVkContactsRecord.find(params[:id])
		resource.destroy unless resource.created_today?
		redirect_to :back
	end
end