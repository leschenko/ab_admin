module AbAdmin
  module Views
    module Helpers
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

      def skype_link(skype, options={})
        return '' if skype.blank?
        link_to skype, "skype:#{skype.strip}?chat", options
      end

      def init_js(js, delayed: false)
        if delayed
          @delayed_js ||= []
          @delayed_js << js
          nil
        else
          %Q[<script type='text/javascript'>$(function(){#{js}})</script>].html_safe
        end
      end

      def render_delayed_js
        return if @delayed_js.blank?
        %Q[<script type='text/javascript'>$(function(){#{@delayed_js.join(';')}})</script>].html_safe
      end

      def image_tag_if(image, options={})
        return unless image
        image_tag image, options
      end
    end
  end
end
