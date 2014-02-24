module AbAdmin
  module Menu
    class Item
      include ::AbAdmin::Utils::EvalHelpers

      def initialize(title, path, options)
        @title = title.is_a?(Symbol) ? I18n.t(title, scope: [:admin, :navigation]) : title
        @path = path
        @options = options
      end

      def render(template)
        return if @options[:if] && !call_method_or_proc_on(template, @options[:if])
        return if @options[:unless] && call_method_or_proc_on(template, @options[:unless])

        active = template.request.path.split('/')[2] == @path.split('/')[2]
        <<-HTML.html_safe
      <li class="#{'active' if active}">#{template.link_to @title, @path, @options.except(:if, :unless)}</li>
        HTML
      end
    end
  end
end
