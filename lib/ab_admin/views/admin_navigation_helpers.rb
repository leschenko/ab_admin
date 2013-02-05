module AbAdmin
  module Views
    module AdminNavigationHelpers

      def search_admin_form_for(object, *args, &block)
        params[:q] ||= {}
        options = args.extract_options!
        options[:html] ||= {}
        options[:html][:id] ||= 'search_form'
        options[:html][:class] ||= 'pjax-form'
        options[:builder] ||= ::AbAdmin::Views::SearchFormBuilder
        options[:method] ||= :get
        form_for([:admin, object].flatten, *(args << options), &block)
      end

      def sort_link(search, attribute, *args)
        options = args.first.is_a?(Hash) ? args.shift.dup : {}
        search_params = params[:q] || {}.with_indifferent_access
        attr_name = (options.delete(:column) || attribute).to_s

        name = attribute.is_a?(Symbol) ? ha(attribute) : attribute

        if existing_sort = search.sorts.detect { |s| s.name == attr_name }
          prev_attr, prev_dir = existing_sort.name, existing_sort.dir
        end

        default_order = options.delete :default_order
        current_dir = prev_attr == attr_name ? prev_dir : nil

        if current_dir
          new_dir = current_dir == 'desc' ? 'asc' : 'desc'
        else
          new_dir = default_order || 'asc'
        end

        html_options = args.first.is_a?(Hash) ? args.shift.dup : {}
        html_options[:class] = ['sort_link', current_dir, html_options[:class]].compact.join(' ')
        options.merge!(:q => search_params.merge(:s => "#{attr_name} #{new_dir}"))

        link_to [name, order_indicator_for(current_dir)].join(' ').html_safe, url_for(options), html_options
      end

      def order_indicator_for(order)
        if order == 'asc'
          '&#9650;'
        elsif order == 'desc'
          '&#9660;'
        else
          '<span class="order_indicator">&#9650;&#9660;</div></span>'
        end
      end

      def short_action_link(action, item)
        case action
          when :new
            item_link_to_can? :create, item, t('admin.actions.new.link'), new_resource_path,
                              :class => 'btn btn-primary'
          when :edit
            item_link_to_can? :update, item, icon('pencil', true), edit_resource_path(item),
                              :class => 'btn btn-primary', :title => t('admin.actions.edit.link')
          when :destroy
            item_link_to_can? :destroy, item, icon('trash', true), resource_path(item, :return_to => request.url),
                              :method => :delete, :data => {:confirm => t('admin.delete_confirmation')},
                              :class => 'btn btn-danger', :title => t('admin.actions.destroy.link')
          when :show
            item_link_to_can? :show, item, icon('info-sign', true), resource_path(item),
                              :class => 'btn btn-info', :title => t('admin.actions.show.link')
          when :preview
            if preview_resource_path(item)
              link_to icon('eye-open', true), preview_resource_path(item),
                      :class => 'btn btn-small btn-inverse', :title => t('admin.actions.preview.link'), :target => '_blank'
            end
          else
            meth = "#{resource_instance_name}_short_action_link"
            send(meth, action, item) if respond_to? meth
        end
      end

      def action_link(action)
        case action
          when :new
            link_to_can? :create, t('admin.actions.new.link'), new_resource_path, :class => 'btn btn-primary'
          when :edit
            link_to_can? :update, t('admin.actions.edit.link'), edit_resource_path, :class => 'btn btn-primary'
          when :destroy
            link_to_can? :destroy, t('admin.actions.destroy.link'), resource_path, :method => :delete, :data => {:confirm => t('admin.delete_confirmation')},
                         :class => 'btn btn-danger'
          when :show
            link_to_can? :show, t('admin.actions.show.link'), resource_path, :class => 'btn btn-info'
          when :preview
            if preview_resource_path(resource)
              link_to t('admin.actions.preview.link'), preview_resource_path(resource), :class => 'btn btn-inverse', :title => t('admin.actions.preview.link'), :target => '_blank'
            end
          when AbAdmin::Config::ActionItem
            instance_exec(&action.data) if action.for_context?(self)
          else
            meth = "#{resource_instance_name}_action_link"
            send(meth, action) if respond_to? meth
        end
      end

      def link_to_can?(act, *args, &block)
        item_link_to_can?(act, get_subject, *args, &block)
      end

      def item_link_to_can?(act, item, *args, &block)
        if can?(act, get_subject)
          if block_given?
            link_to(*args, &block)
          else
            link_to(*args)
          end
        end
      end

      def model_admin_menu_link(model)
        content_tag :li, :class => ('active' if controller_name.split('/').last == model.model_name.plural) do
          link_to model.model_name.human(:count => 9), "/admin/#{model.model_name.plural}"
          #link_to model.model_name.human(:count => 9), {:action => :index, :controller => "admin/#{model.model_name.plural}"}
        end
      end

      def admin_menu_link(name, path)
        content_tag :li, :class => ('active' if path == request.path_info.split('/')[2]) do
          link_to name, "/admin/#{path}"
        end
      end

      def admin_menu_link_without_model(name, path, path_name)
        content_tag :li, :class => ('active' if path_name == request.url.split('/').last) do
          link_to name, path
        end
      end

      def pagination_info(c)
        offset = c.offset
        total_entries = c.total_entries
        if total_entries.zero?
          t('will_paginate.pagination_info_empty')
        else
          per_page = (params[:per_page] || resource_class.per_page).to_i
          t('will_paginate.pagination_info', :from => offset + 1, :to => [offset + per_page, total_entries].min, :count => total_entries).html_safe
        end
      end

      def item_index_actions(item)
        index_actions.map do |act|
          short_action_link(act, item)
        end.join(' ').html_safe
      end

      def batch_action_toggle
        if settings[:batch]
          content_tag :th do
            check_box_tag '', '', false, :id => nil, :class => 'toggle'
          end
        end
      end

      def batch_action_item(item)
        if settings[:batch]
          content_tag :td do
            check_box_tag 'ids[]', item.id, false, :id => "batch_action_item_#{item.id}"
          end
        end
      end

      def id_link(item)
        if can?(:edit, item)
          link_to item.id, edit_resource_path(item), :class => 'resource_id_link'
        elsif can?(:read, item)
          link_to item.id, resource_path(item), :class => 'resource_id_link'
        else
          item.id
        end
      end

      def auto_edit_link(rec, opts = {})
        return if !rec || cannot?(:edit, rec)
        admin_edit_link(rec, opts)
      end

      def auto_show_link(rec, opts = {})
        return if !rec || cannot?(:read, rec)
        admin_show_link(rec, opts)
      end

      def admin_edit_link(record, options = {})
        admin_record_link(record, :edit, options)
      end

      def admin_show_link(record, options = {})
        admin_record_link(record, :show, options)
      end

      def admin_record_link(record, action, options={})
        return unless record
        record_title = options.delete(:title) || AbAdmin.display_name(record)
        #url_options = {:controller => record.class.model_name.plural, :action => action, :id => record.id}
        action_url_part = action == :show ? '' : "/#{action}"
        url = "/admin/#{record.class.model_name.plural}/#{record.id}#{action_url_part}"
        html_options = options.delete(:html_options) || {}
        link_to record_title, url, html_options
      end

    end
  end
end