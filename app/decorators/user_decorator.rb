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
		if _skype.nil?
			h.ah_txt_or_not_given_what(_skype, h.t('translations.skype'))
		else
			h.link_to(h.fa_icon('skype', text: _skype), "skype:#{_skype}?chat")
		end
	end

	def pricing_plan_purchased?(name)
		case name
		when :vk_contacts_collector
			!vcc_permission.package.blank?
		else
			false
		end
	end

	def profile_fields_filled?
		!(user_profile.first_name.blank? or
			user_profile.last_name.blank? or
			user_profile.skype.blank? or
			user_profile.username.blank?)
	end

	def referral_balance
		(referral_earned - referral_paid_out).round(2)
	end

	def has_at_least_1_social_network_link?
		!(user_profile.vk_url.blank? and
			user_profile.facebook_url.blank? and
			user_profile.odnoklassniki_url.blank? and
			user_profile.google_plus_url.blank? and
			user_profile.youtube_chanel_url.blank? and
			user_profile.skype.blank?)
	end

	def vk_contacts_requests_count(date)
		case date
		when :today
			((_count = user_vk_contacts_records.created_today.select('vk_source_identifier').distinct.count) > 0) ? _count : 0
		else
			0
		end
	end

	def vk_contacts_request_left
		if (res = vcc_permission.requests_limit_per_day - vk_contacts_requests_count(:today)) > 0
			res
		else
			0
		end
	end

	def current_vcc_package
		if (_p = vcc_permission.package).nil?
			h.t('translations.nah')
		else
			_p.camelcase
		end
	end
end
