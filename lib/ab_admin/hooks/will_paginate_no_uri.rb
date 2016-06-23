# add `:no_uri` options to skip query params in pagination urls
require 'will_paginate/view_helpers/action_view'

WillPaginate::ViewHelpers.pagination_options[:no_uri] = false
WillPaginate::ActionView::LinkRenderer.class_exec do
  def url(page)
    @base_url_params ||= begin
      url_params = merge_get_params(default_url_params)
      merge_optional_params(url_params)
    end

    url_params = @base_url_params.dup
    add_current_page_param(url_params, page)
    url_params[param_name.to_sym] = nil if url_params[param_name.to_sym].to_i < 2

    link = @template.url_for(url_params)
    @options[:no_uri] ? link.split('?').first : link.sub(/\?\z/, '')
  end
end
