module AbAdmin
  module Menu
    class Item
      include ::AbAdmin::Utils::EvalHelpers

      def initialize(title, url, options)
        @title = title.is_a?(Symbol) ? I18n.t(title, scope: [:admin, :navigation]) : title
        @url = url
        @options = options
      end

      def render(template)
        return if @options[:if] && !call_method_or_proc_on(template, @options[:if])
        return if @options[:unless] && call_method_or_proc_on(template, @options[:unless])

        item_url = @url.is_a?(String) ? @url : call_method_or_proc_on(template, @url)
        active = template.request.path.split('/')[2] == item_url.split('/')[2]

        <<-HTML.html_safe
          <li class="#{'active' if active}">#{template.link_to title(template), item_url, @options.except(:if, :unless)}</li>
        HTML
      end

      private

      def title(template)
        ActiveSupport::Deprecation.warn('Menu item :badge_counter option is deprecated, use :badge instead') if @options[:badge_counter]
        return @title unless @options[:badge]
        badge = call_method_or_proc_on(template, @options[:badge])
        return @title if !badge || badge == 0
        "#{@title}&nbsp;<span class='badge badge-#{@options[:badge_type] || 'important'}'>#{badge}</span>".html_safe
      end
    end
  end
end
