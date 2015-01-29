class UserDecorator < Draper::Decorator
	delegate_all

	def full_name
		_full_name = '%s %s' % [user_profile.first_name, user_profile.last_name]
		h.ah_txt_or_not_given_what(_full_name, h.t('translations.full_name'))
	end

	def address
		h.raw('%s, %s' % [
				h.ah_txt_or_not_given(user_profile.country),
				h.ah_txt_or_not_given(user_profile.city)
			])
	end

	def country
		_country = user_profile.country
		h.ah_txt_or_not_given_what(_country, h.t('translations.country'))
	end

	def contact_phone
		_contact_phone = user_profile.contact_phone
		h.ah_txt_or_not_given_what(_contact_phone, h.t('translations.contact_phone'))
	end

	def first_name
		_first_name = user_profile.first_name
		h.ah_txt_or_not_given_what(_first_name, h.t('translations.first_name'))
	end

	def last_name
		_last_name = user_profile.last_name
		h.ah_txt_or_not_given_what(_last_name, h.t('translations.last_name'))
	end

	def about
		_about = user_profile.about
		h.ah_txt_or_not_given_what(_about, h.t('translations.about'))
	end

	def city
		_city = user_profile.city
		h.ah_txt_or_not_given_what(_city, h.t('translations.city'))
	end

	def contact_email
		_contact_email = user_profile.contact_email
		h.ah_txt_or_not_given_what(_contact_email, h.t('translations.contact_email'))
	end

	def vkontakte_id
		_vkontakte_id = user_profile.vkontakte_id
		h.ah_txt_or_not_given_what(_vkontakte_id, h.t('translations.vkontakte_id'))
	end

	def facebook_id
		_facebook_id = user_profile.facebook_id
		h.ah_txt_or_not_given_what(_facebook_id, h.t('translations.facebook_id'))
	end

	def twitter_id
		_twitter_id = user_profile.twitter_id
		h.ah_txt_or_not_given_what(_twitter_id, h.t('translations.twitter_id'))
	end

	def skype
		_skype = user_profile.skype
		h.ah_txt_or_not_given_what(_skype, h.t('translations.skype'))
	end

	def last_n_vk_contacts_files(number)
		user_vk_contacts_files.unarchived.vk_contacts_file_included.order('user_vk_contacts_files.created_at DESC').last(number)
		# VkContactsFile.joins(:user_vk_contacts_file).where(user_vk_contacts_files: { archived: false, user_id: object.id }).order('created_at DESC').last(5)
	end

	def pricing_plan_purchased?(name)
		case name
		when :vk_contacts_collector
			user_permission.user_vk_contacts_files_create? or
				user_permission.user_vk_contacts_files_read? or
				user_permission.user_vk_contacts_files_update?
		else
			false
		end
	end
end
