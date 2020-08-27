module AbAdmin
  module Menu
    class BaseGroup
      include ::Rails.application.routes.url_helpers

      def link(title, path, options={})
        @menu_tree << Item.new(title, path, options)
      end

      def model(model, options={})
        title = options[:title] || model.model_name.human(count: 9)
        url = options[:url] || "/admin/#{model.model_name.plural}"
        @menu_tree << Item.new(title, url, options)
      end

      def group(title, options={}, &block)
        @menu_tree << Group.new(title, options, &block)
      end

      def render_nested(template)
        @menu_tree.map { |item| item.render(template) }.compact.join.html_safe
      end
    end
  end
end
