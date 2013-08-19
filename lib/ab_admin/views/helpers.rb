# -*- encoding : utf-8 -*-
module AbAdmin
  module Views
    module Helpers

      CLEAN_SEPARATOR_REGEXP = /\s?(—|-|—|,|\.|\|)(?=\s(\||—|-|,|\.))/

      def pjax?
        request.headers['X-PJAX']
      end

      def admin?
        user_signed_in? && current_user.admin?
      end

      def moderator?
        user_signed_in? && current_user.moderator?
      end

      def as_html(text)
        return ''.html_safe if text.nil?
        Nokogiri::HTML.fragment(text).to_html.html_safe
      end

      def full_locale
        case I18n.locale
          when :en
            'en_US'
          when :ru
            'ru_RU'
          when :it
            'it_IT'
          when :uk
            'uk_UA'
          else
            'ru_RU'
        end
      end

      def locale_path
        I18n.locale == I18n.default_locale ? '' : "/#{I18n.locale}"
      end
      #
      #def external_link(raw_link, options={}, &block)
      #  return unless raw_link.present?
      #  options.reverse_merge!(title: raw_link, target: '_blank', rel: 'nofollow')
      #  link = raw_link =~ /^http[s]?:\/\// ? raw_link : "http://#{raw_link}"
      #  if block_given?
      #    link_to link, options, &block
      #  else
      #    link_to options[:title], link, options
      #  end
      #end

      def skype_link(skype, options={})
        return '' if skype.blank?
        link_to skype, "skype:#{skype.strip}?chat", options
      end

      def init_js(js)
        %Q[<script type='text/javascript'>$(function(){#{js}})</script>].html_safe
      end

      def image_tag_if(image, options={})
        return unless image
        image_tag image, options
      end

      def render_title
        (@page_title || @meta_tags_builder.try(:title) || I18n.t('page.title')).sub(CLEAN_SEPARATOR_REGEXP, '')
      end

      def render_keywords
        @page_keywords || @meta_tags_builder.try(:keywords) || I18n.t('page.keywords')
      end

      def render_description
        @page_description || @meta_tags_builder.try(:description) || I18n.t('page.description')
      end

      def render_h1
        @page_h1 || @meta_tags_builder.try(:h1)
      end

      # swf_object
      def swf_object(swf, id, width, height, flash_version, options = {})
        options.symbolize_keys!

        params = options.delete(:params) || {}
        attributes = options.delete(:attributes) || {}
        flashvars = options.delete(:flashvars) || {}

        attributes[:classid] ||= 'clsid:D27CDB6E-AE6D-11cf-96B8-444553540000'
        attributes[:id] ||= id
        attributes[:name] ||= id

        output_buffer = ActiveSupport::SafeBuffer.new

        if options[:create_div]
          output_buffer << content_tag(:div,
                                       "This website requires <a href='http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash&promoid=BIOW' target='_blank'>Flash player</a> #{flash_version} or higher.",
                                       id: id)
        end

        js = []

        js << "var params = {#{params.to_a.map { |item| "#{item[0]}:'#{item[1]}'" }.join(',')}};"
        js << "var attributes = {#{attributes.to_a.map { |item| "#{item[0]}:'#{item[1]}'" }.join(',')}};"
        js << "var flashvars = {#{flashvars.to_a.map { |item| "#{item[0]}:'#{item[1]}'" }.join(',')}};"

        js << "swfobject.embedSWF('#{swf}', '#{id}', '#{width}', '#{height}', '#{flash_version}', '/swf/expressInstall.swf', flashvars, params, attributes);"

        output_buffer << javascript_tag(js.join)

        output_buffer
      end

    end
  end
end
