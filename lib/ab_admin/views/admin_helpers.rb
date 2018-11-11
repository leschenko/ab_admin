module AbAdmin
  module Views
    module AdminHelpers

      def admin_form_for(object, *args, &block)
        record = Array(object).last
        record.fallbacks_for_empty_translations = false if record.respond_to?(:fallbacks_for_empty_translations)
        options = args.extract_options!
        options[:remote] = true if request.xhr?
        options[:html] ||= {}
        options[:html][:class] ||= 'form-horizontal'
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

      def admin_editable(item, attr, options=nil)
        options = {} unless options.is_a?(Hash)
        title = options[:title] || item[attr]
        html_title = admin_pretty_data(title).to_s.html_safe
        return html_title unless can?(:update, item)
        options[:source] = options[:collection].is_a?(Hash) ? options[:collection] : options[:collection].map{|r| [r.id, AbAdmin.display_name(r)] }.to_h if options[:collection]

        unless options[:type]
          if options[:source]
            options[:type] = 'select'
          else
            case attr.to_s
              when /_at$/
                options[:type] ||= 'date'
              when /^is_/
                options[:type] ||= 'select'
                options[:source] ||= {1 => 'yes', 0 => 'no'}
                options[:value] ||= item[attr] ? 1 : 0
                options[:title] ||= item[attr] ? 'yes' : 'no'
              when /description|body|content/
                options[:type] ||= 'textarea'
              else
                options[:type] ||= 'text'
            end
          end
        end

        data = {
            type: options[:type],
            source: options[:source].try(:to_json),
            model: options[:model] || item.class.model_name.singular,
            accept: options[:accept],
            url: options[:url] || "/admin/#{item.class.model_name.plural}/#{item.id}",
            name: attr,
            value: options[:value] || item[attr],
            title: options[:title] || item[attr]
        }
        link_to html_title, '#', class: "editable #{options[:class]}", data: data.update(options[:data] || {})
      end

      def options_for_ckeditor(options = {})
        {width: 930, height: 200, toolbar: 'VeryEasy', namespace: ''}.update(options)
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
        css << 'well' if settings[:well] && current_index_view != 'tree'
        css << "#{current_index_view}_view"
        css
      end

      def admin_title
        base = @breadcrumbs ? @breadcrumbs.map_val(:name).reverse : []
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

      def icon(name, white=false)
        "<i class='icon-#{name} #{'icon-white' if white}'></i> ".html_safe
      end

      def admin_pretty_data(object)
        case object
          when String, Integer, BigDecimal, Float
            object
          when TrueClass, FalseClass
            color_bool(object)
          when Date, DateTime, Time, ActiveSupport::TimeWithZone
            I18n.l(object, format: :long)
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

      def per_page_variants
        AbAdmin.per_page_variants.map{|variant| [variant, max_per_page].min }.uniq
      end

      # input_set 'title', legend_class: 'do_sort', label_class: 'label-info' do
      def input_set(title, options={}, &block)
        options.reverse_merge!(class: "inputs well well-small clearfix #{options.delete(:legend_class) || 'do_sort'}", id: options.delete(:legend_id))
        html = content_tag(:label, title, class: "input_set label #{options.delete(:label_class)}")
        html.concat(capture(&block)) if block_given?
        content_tag(:div, html, options)
      end

      def ha(attr)
        resource_class.han(attr)
      end

      def call_method_or_proc_on(obj, symbol_or_proc, options = {})
        exec = options[:exec].nil? ? true : options[:exec]
        case symbol_or_proc
          when Symbol, String
            obj.send(symbol_or_proc.to_sym)
          when Proc
            exec ? instance_exec(obj, &symbol_or_proc) : symbol_or_proc.call(obj)
        end
      end

    end
  end
end
