module AbAdmin
  module Menu
    class Item
      def initialize(title, url, options)
        @title = title.is_a?(Symbol) ? I18n.t(title, scope: [:admin, :navigation]) : title
        @url = url
        @options = options
      end

      def render(template)
        return unless template.option_conditions_met?(@options)

        item_url = @url.is_a?(String) ? @url : template.instance_exec(&@url)
        active = template.request.path.split('/')[2] == item_url.split('/')[2]

        <<-HTML.html_safe
          <li class="#{'active' if active}">#{template.link_to title(template), item_url, @options.except(:if, :unless)}</li>
        HTML
      end

      private

      def title(template)
        return @title unless @options[:badge]
        badge = @options[:badge].is_a?(Symbol) ? template.public_send(@options[:badge]) : template.instance_exec(&@options[:badge])
        return @title if !badge || badge == 0
        "#{@title}&nbsp;<span class='badge badge-#{@options[:badge_type] || 'important'}'>#{badge}</span>".html_safe
      end
    end
  end
end
