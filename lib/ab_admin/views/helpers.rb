# -*- encoding : utf-8 -*-
module AbAdmin
  module Views
    module Helpers

      def init_js(js)
        %Q[<script type='text/javascript'>$(function(){#{js}})</script>].html_safe
      end

      def render_title
        @page_title || I18n.t("page.title")
      end

      def render_keywords
        @page_keywords || I18n.t("page.keywords")
      end

      def render_description
        @page_description || I18n.t("page.description")
      end

      # swf_object
      def swf_object(swf, id, width, height, flash_version, options = {})
        options.symbolize_keys!

        params = options.delete(:params) || {}
        attributes = options.delete(:attributes) || {}
        flashvars = options.delete(:flashvars) || {}

        attributes[:classid] ||= "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
        attributes[:id] ||= id
        attributes[:name] ||= id

        output_buffer = ActiveSupport::SafeBuffer.new

        if options[:create_div]
          output_buffer << content_tag(:div,
                                       "This website requires <a href='http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash&promoid=BIOW' target='_blank'>Flash player</a> #{flash_version} or higher.",
                                       :id => id)
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
