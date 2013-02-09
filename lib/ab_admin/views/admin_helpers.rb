module AbAdmin
  module Views
    module AdminHelpers

      def admin_form_for(object, *args, &block)
        options = args.extract_options!
        options[:html] ||= {}
        options[:html][:class] ||= 'form-horizontal'
        options[:builder] ||= ::AbAdmin::Views::FormBuilder
        options[:html]['data-id'] = Array(object).last.id
        if controller_name == 'manager'
          options[:url] ||= object.new_record? ? collection_path : resource_path
        end
        if options.delete(:nested)
          simple_nested_form_for([:admin, object].flatten, *(args << options), &block)
        else
          simple_form_for([:admin, object].flatten, *(args << options), &block)
        end
      end

      def options_for_ckeditor(options = {})
        {:width => 930, :height => 200, :toolbar => 'VeryEasy', :namespace => ''}.update(options)
      end

      def admin_tree_item(item)
        render 'tree_item', :item => item, :child_tree => admin_tree(item.cached_children)
      end

      def admin_tree(items)
        return if items.blank?
        items.map { |item| admin_tree_item(item) }.join.html_safe
      end

      def layout_css
        css = []
        css << 'content_with_sidebar' if settings[:sidebar]
        css << 'well' if settings[:well]
        css << "#{settings[:index_view]}_view"
        css
      end

      def admin_comments
        render 'admin/admin_comments/comments'
      end

      def color_bool(val, success_class='badge-success')
        %(<span class="badge #{success_class if val}">#{val ? '+' : '-'}</span>).html_safe
      end

      def icon(name, white=false)
        "<i class='icon-#{name} #{'icon-white' if white}'></i> ".html_safe
      end

      def admin_pretty_data(object)
        case object
          when String, Integer
            object
          when TrueClass, FalseClass
            color_bool(object)
          when Date, DateTime, Time, ActiveSupport::TimeWithZone
            I18n.l(object, :format => :long)
          when NilClass
            ''
          when ActiveRecord::Base
            admin_show_link(object)
          else
            AbAdmin.safe_display_name(object)
        end
      end

      def pretty_data(object)
        AbAdmin.pretty_data(object)
      end

      def item_image_link(item, options={})
        options.reverse_merge!(:url => resource_path(item), :assoc => :picture)
        image = item.send(options[:assoc])
        return nil unless image
        version = options[:version] || image.class.thumb_size
        popover_data = {:content => "<img src='#{image.url}'></img>", :title => item.name}
        link_to image_tag(image.url(version)), options[:url], :data => popover_data, :rel => 'popover'
      end

      def item_image(item, assoc=:photo, size=:thumb)
        image_tag_if(item.send(assoc).try(:url, size))
      end

      # input_set 'title', :legend_class => 'do_sort', :label_class => 'label-info' do
      def input_set(title, options={}, &block)
        options.reverse_merge!(:class => "inputs well well-small #{options.delete(:legend_class) || 'do_sort'}", :id => options.delete(:legend_id))
        html = content_tag(:label, title, :class => "input_set label #{options.delete(:label_class)}")
        html.concat(capture(&block)) if block_given?
        content_tag(:fieldset, html, options)
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
            if exec
              instance_exec(obj, &symbol_or_proc)
            else
              symbol_or_proc.call(obj)
            end
        end
      end

    end
  end
end
