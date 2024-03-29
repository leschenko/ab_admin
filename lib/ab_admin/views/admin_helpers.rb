module AbAdmin
  module Views
    module AdminHelpers
      def admin_form_for(object, *args, &block)
        record = Array(object).last
        record.fallbacks_for_empty_translations = false if record.respond_to?(:fallbacks_for_empty_translations)
        options = args.extract_options!
        options[:wrapper] = :bootstrap
        options[:remote] = true if request.xhr?
        options[:html] ||= {}
        options[:html][:class] = Array(options[:html][:class])
        options[:html][:class] << 'form-horizontal' if options[:html][:class].empty?
        options[:html][:class] << 'save-error' if Array(object).last.errors.of_kind?(:base, :changed)
        options[:builder] ||= ::AbAdmin::Views::FormBuilder
        options[:html]['data-id'] = record.id
        if controller_name == 'manager' && resource_class == Array(object).last.class
          options[:url] ||= object.new_record? ? collection_path : resource_path
        end
        if options.delete(:nested)
          simple_nested_form_for([:admin, object].flatten, *(args << options), &block)
        else
          simple_form_for([:admin, object].flatten, *(args << options), &block)
        end
      end

      def editable_bool(item, attr, label: nil, wrapper_class: nil)
        url = "/admin/#{item.class.model_name.plural}/#{item.id}.json"
        html = check_box_tag("#{item.class.model_name.singular}[#{attr}]", '1', item.send(attr), class: 'js-auto-submit-checkbox', data: {url: url})
        html = content_tag(:label, "#{label}&nbsp;#{html}".html_safe) if label
        content_tag :div, html, class: ['auto-submit-checkbox-wrap', 'white-space-nowrap', ('tool' unless label), wrapper_class], title: attr
      end

      def admin_editable(item, attr, opts=nil)
        opts = {} unless opts.is_a?(Hash)
        if opts[:title]
          title = opts[:title]
        else
          assoc_name = attr.to_s.remove('_id')
          title = item.class.reflect_on_association(assoc_name) ? AbAdmin.display_name(item.send(assoc_name)) : item[attr]
        end
        html_title = admin_pretty_data(title).to_s.html_safe
        return html_title unless can?(:update, item)

        if opts[:collection]
          if opts[:collection].is_a?(Hash)
            opts[:source] = opts[:collection]
          elsif opts[:collection].is_a?(Array)
            opts[:source] = opts[:collection].first.respond_to?(:id) ? opts[:collection].map {|r| [r.id, AbAdmin.display_name(r)]}.to_h : opts[:collection].map {|v| [v, v]}.to_h
          end
        end

        if opts[:source]
          opts[:type] ||= 'select'
        else
          case attr.to_s
          when /_at$/
            opts[:type] ||= 'date'
            opts[:title] ||= html_title
            opts[:value] ||= item[attr].try! { _1.to_fs(:db).split.first.html_safe }
          when /^is_/
            opts[:type] ||= 'select'
            opts[:source] ||= { 1 => 'yes', 0 => 'no' }
            opts[:value] ||= item[attr] ? 1 : 0
            opts[:title] ||= item[attr] ? 'yes' : 'no'
          when /description|body|content/
            opts[:type] ||= 'textarea'
          else
            opts[:type] ||= 'text'
          end
        end

        data = {
            type: opts[:type],
            source: opts[:source].try(:to_json),
            model: opts[:model] || item.class.model_name.singular,
            accept: opts[:accept],
            url: opts[:url] || "/admin/#{item.class.model_name.plural}/#{item.id}",
            name: attr,
            value: opts[:value] || item[attr],
            title: opts[:title] || item[attr]
        }
        link_to html_title, '#', class: "editable #{opts[:class]}", placeholder: opts[:placeholder], data: data.update(opts[:data] || {})
      end

      def options_for_ckeditor(options = {})
        {width: 930, height: 200, namespace: ''}.update(options)
      end

      def admin_tree_item(item)
        render 'tree_item', item: item, child_tree: admin_tree(item.cached_children)
      end

      def admin_tree(items)
        return if items.blank?
        items.map { |item| admin_tree_item(item) }.join.html_safe
      end

      def admin_layout_css
        css = []
        css << 'content_with_sidebar' if settings[:sidebar] || content_for?(:sidebar)
        css << 'well' if !@settings[:well].is_a?(FalseClass) && (collection_action? || %w(show history).include?(action_name)) && @settings[:current_index_view] != :tree
        css << "#{settings[:current_index_view]}_view"
        css
      end

      def admin_title
        base = @breadcrumbs ? @breadcrumbs.map{|b| b[:name] }.reverse : []
        base << @page_title || 'Ab Admin'
        base.join(' - ')
      end

      def include_fv
        "<script type='text/javascript'>window.fv = #{fv.to_h.to_json}</script>".html_safe
      end

      def admin_comments
        render 'admin/admin_comments/comments'
      end

      def color_bool(val, options={})
        options.reverse_merge!(true_css: 'badge-success', false_css: nil, nil_css: nil)
        css = options["#{val.inspect}_css".to_sym]
        text = val.nil? ? '?' : (val ? '+' : '-')
        %(<span class="badge #{css}">#{text}</span>).html_safe
      end

      def icon(name, white=false, title: nil)
        title_html = %( title="#{h(title)}") if title
        "<i class='icon-#{name}#{' icon-white' if white}#{' tool' if title}'#{title_html}></i> ".html_safe
      end

      def locale_flag(code)
        (AbAdmin.locale_to_country_code[code] || code).to_s[0..1].upcase.tr('A-Z', '🇦-🇿')
      end

      def admin_pretty_data(object)
        case object
          when Integer, BigDecimal, Float
            object
          when String
            object.html_safe? ? object : object.no_html.gsub("\n", '<br/>').html_safe
          when TrueClass, FalseClass
            color_bool(object)
          when Date
            I18n.l(object, format: AbAdmin.date_format)
          when DateTime, Time, ActiveSupport::TimeWithZone
            I18n.l(object, format: AbAdmin.datetime_format)
          when NilClass
            ''
          when ActiveRecord::Base
            admin_show_link(object)
          else
            AbAdmin.safe_display_name(object) || object
        end
      end

      def pretty_data(object)
        AbAdmin.pretty_data(object)
      end

      def item_image_link(item, options={})
        options.reverse_merge!(assoc: :picture)
        options[:url] ||= resource_path(item)
        image = item.send(options[:assoc])
        return nil unless image
        version = options[:version] || image.class.thumb_size
        image_url_method = options[:image_url_method] || :url
        popover_content = "<img class='image_link_popover popover_#{options[:assoc]}' src='#{image.send(image_url_method, options[:full_version])}'></img>"
        popover_data = {content: popover_content, title: AbAdmin.display_name(item)}

        html_options = options.delete(:html_options) || {}
        html_options.reverse_merge!(rel: 'popover', remote: options[:remote], data: popover_data)
        link_to image_tag(image.send(image_url_method, version)), options[:url], html_options
      end

      def item_image(item, assoc=:photo, size=:thumb)
        image_tag_if(item.send(assoc).try(:url, size))
      end

      # input_set 'title', legend_class: 'do_sort', label_class: 'label-info' do
      def input_set(title, options={}, &block)
        options.reverse_merge!(class: "inputs well well-small clearfix #{options.delete(:legend_class) || 'do_sort'}", id: options.delete(:legend_id))
        html = title ? content_tag(:label, title, class: "input_set label #{options.delete(:label_class)}") : ''.html_safe
        html.concat(capture(&block)) if block_given?
        content_tag(:div, html, options)
      end

      def copy_btn(text, btn_text: nil, tooltip: false)
        return if text.blank?
        content_tag(:div, "#{icon('share')} #{btn_text}".html_safe, 'data-clipboard-text' => text, class: ['btn', 'btn-mini', 'js-copy', ('tool' if tooltip)], title: (text.no_html if tooltip))
      end

      def ha(attr)
        resource_class.han(attr)
      end

      def admin_site_name
        AbAdmin.site_name.is_a?(String) ? AbAdmin.site_name : AbAdmin.site_name.call
      end

      def option_conditions_met?(options, object=nil)
        return true unless options
        condition = options[:if] || options[:unless]
        return true unless condition
        options[:if] ? method_or_proc_on(condition, object) : !method_or_proc_on(condition, object)
      end

      def method_or_proc_on(symbol_or_proc, object=nil)
        return unless symbol_or_proc
        if symbol_or_proc.is_a?(Symbol)
          (object || self).public_send(symbol_or_proc)
        else
          object ? instance_exec(object, &symbol_or_proc) : instance_exec(&symbol_or_proc)
        end
      end
    end
  end
end
