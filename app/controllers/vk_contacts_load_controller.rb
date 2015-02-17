require 'lzma'

class VkContactsLoadController < ApplicationController
	def upload_contacts
		authorize! :create, UserVkContactsRecord

		vk_c_record_name = params[:vk_contacts_record_name]
		# vk_c_source_name = params[:vk_contacts_source_name]
		vk_c_source_identifier = params[:vk_contacts_source_identifier]

		# vk_contacts_json = LZMA.decompress(
		# 	params[:vk_contacts_json]
		# 		.split(' ')
		# 		.map(&:hex)
		# 		.map { |n| n.chr }
		# 		.reduce(:+)
		# ).force_encoding('UTF-8')

		vk_contacts_json = params[:vk_contacts_json]

		# if vk_c_source_name and vk_c_source_identifier and vk_contacts_json
		if vk_c_record_name and vk_c_source_identifier and vk_contacts_json
			ProcessVkContactsWorker.tap do |klass|
				if Rails.env.test?
					# klass.new.perform(vk_c_source_name, vk_c_source_identifier, vk_contacts_json, current_user.id)
					klass.new.perform(vk_c_record_name, vk_c_source_identifier, vk_contacts_json, current_user.id)
				else
					# klass.perform_async(vk_c_source_name, vk_c_source_identifier, vk_contacts_json, current_user.id)
					klass.perform_async(vk_c_record_name, vk_c_source_identifier, vk_contacts_json, current_user.id)
				end
			end

			respond_to do |format|
				format.html { load_contacts_render_html(:success, 'sent to processing') }
				format.json { render json: { status: 'success', message: 'sent to processing' } }
			end
		else
			respond_to do |format|
				format.html { load_contacts_render_html(:error, 'invalid params') }
				format.json { render json: { status: 'error', message: 'invalid params' } }
			end
		end
	end

	private

	def load_contacts_render_html(status, msg)
		if status == :error
			opts = { alert: 'invalid params' }
		else
			opts = { notice: 'sent to processing' }
		end

		if params[:redirect_to].nil? or params[:redirect_to].blank?
			redirect_to :work_root, opts
		else
			redirect_to params[:redirect_to], opts
		end
	end

	def load_contacts_params
		params.permit(:vk_contacts_source_name, :vk_contacts_source_identifier, :vk_contacts_json)
	end
end