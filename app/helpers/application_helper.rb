module ApplicationHelper
	def ah_ibox(opts = {})
		default_opts = { class: 'ibox float-e-margins' }
		content_tag(:div, default_opts.merge(opts)) do
			yield
		end
	end

	def ah_ibox_title(title)
		content_tag(:div, class: 'ibox-title') do
			content_tag(:h5, title)
		end
	end

	def ah_ibox_content(opts={})
		content_tag(:div, class: 'ibox-content %s' % [opts[:class]]) do
			yield
		end
	end

	def ah_ibox_heading
		content_tag(:div, class: 'ibox-content ibox-heading') do
			yield
		end
	end

	def ah_markdown(text)
		extensions = { space_after_headers: true, strikethrough: true, autolink: true, no_intra_emphasis: true }
		render_options = { hard_wrap: true }
		raw Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(render_options), extensions).render(text)
	end

	def ah_txt_or_not_given(txt)
		(txt.nil? or txt.blank?) ? ah_muted(t('translations.not_given')) : txt
	end

	def ah_txt_or_not_given_what(txt, what)
		(txt.nil? or txt.blank?) ? ah_muted(t('translations.not_given_what', what: what)) : txt
	end

	def ah_muted(text)
		content_tag(:span, class: 'text-muted') { text }
	end

	def ah_prepend_host(path)
		"#{request.protocol}#{request.host_with_port}#{path}"
	end
end
