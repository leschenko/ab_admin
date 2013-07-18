module AbAdmin

  class BaseMenuGroup
    include Rails.application.routes.url_helpers
    include ::AbAdmin::Utils::EvalHelpers

    def link(title, path, options={})
      @menu_tree << MenuItem.new(title, path, options)
    end

    def model(model, options={})
      title = model.model_name.human(count: 9)
      path = options[:url] || "/admin/#{model.model_name.plural}"
      @menu_tree << MenuItem.new(title, path, options)
    end

    def group(title, options={}, &block)
      @menu_tree << MenuGroup.new(title, options, &block)
    end

    def render_nested(template)
      @menu_tree.map { |item| item.render(template) }.compact.join.html_safe
    end
  end

  class MenuBuilder < BaseMenuGroup
    include Singleton

    def self.draw(&block)
      I18n.locale = AbAdmin.locale
      instance.instance_eval &block if block_given?
    end

    def initialize
      @menu_tree = []
    end

    def render(template, options={})
      inner = render_nested(template)
      options[:skip_wrap] ? inner.html_safe : %[<ul class="nav">#{inner}</ul>].html_safe
    end

    def self.render(*args)
      instance.render(*args)
    end
  end

  class MenuGroup < BaseMenuGroup
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
            <a class="dropdown-toggle" data-toggle="dropdown" href="#" >#{@title}<b class="caret"></b></a>
            <ul class="dropdown-menu">#{render_nested(template)}</ul>
          <li>
      HTML
    end
  end

  class MenuItem
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
          <li class="#{'active' if active}">#{template.link_to @title, @path, @options}</li>
      HTML
    end
  end

end