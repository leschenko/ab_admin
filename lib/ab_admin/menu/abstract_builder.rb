module AbAdmin
  module Menu
    class AbstractBuilder < BaseGroup
      def initialize
        @menu_tree = []
      end

      def render(template, options={})
        inner = render_nested(template)
        options[:skip_wrap] ? inner.html_safe : %[<ul class="nav">#{inner}</ul>].html_safe
      end
    end
  end
end
