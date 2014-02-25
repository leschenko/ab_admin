module AbAdmin
  module Menu
    class Group < BaseGroup
      def initialize(title, options, &block)
        @menu_tree = []
        @title = title.is_a?(Symbol) ? I18n.t(title, scope: [:admin, :navigation]) : title
        @options = options
        instance_eval &block if block_given?
      end

      def render(template)
        return if @options[:if] && !call_method_or_proc_on(template, @options[:if])
        return if @options[:unless] && call_method_or_proc_on(template, @options[:unless])

        <<-HTML.html_safe
      <li class="dropdown">
        <a class="dropdown-toggle" href="#{@options[:url] || '#'}" >#{@title}<b class="caret"></b></a>
        <ul class="dropdown-menu">#{render_nested(template)}</ul>
      <li>
        HTML
      end
    end
  end
end
