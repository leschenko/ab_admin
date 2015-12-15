module AbAdmin
  module Menu
    class Group < BaseGroup
      def initialize(title, options, &block)
        @menu_tree = []
        @raw_title = title
        @title = title.is_a?(Symbol) ? I18n.t(title, scope: [:admin, :navigation]) : title
        @options = options
        instance_eval &block if block_given?
      end

      def render(template)
        return if @options[:if] && !call_method_or_proc_on(template, @options[:if])
        return if @options[:unless] && call_method_or_proc_on(template, @options[:unless])

        wrapper_class = "dropdown-wrap-#{@raw_title}" if @raw_title.is_a?(Symbol)
        <<-HTML.html_safe
      <li class="dropdown #{wrapper_class}">
        <a class="dropdown-toggle" href="#{@options[:url] || '#'}" >#{title(template)}<b class="caret"></b></a>
        <ul class="dropdown-menu">#{render_nested(template)}</ul>
      <li>
        HTML
      end

      private

      def title(template)
        return @title unless @options[:badge]
        badge = call_method_or_proc_on(template, @options[:badge])
        return @title if !badge || badge == 0
        "#{@title}&nbsp;<span class='badge badge-#{@options[:badge_type] || 'important'}'>#{badge}</span>".html_safe
      end
    end
  end
end
