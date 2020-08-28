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
        options[:compact_labels] = settings.dig(:search_form, :compact_labels)
        options[:method] ||= :get
        options[:as] ||= 'q'
        form_for([:admin, object].flatten, *(args << options), &block)
      end

      def list_sort_link(attribute, options={})
        adapter = options[:adapter] || ransack_collection
        if adapter && adapter.klass == resource_class
          sort_link(adapter, attribute, options)
        else
          options[:title] || (attribute.is_a?(Symbol) ? ha(attribute) : attribute)
        end
      end

      def sort_link(adapter, attribute, options={})
        name = options.delete(:title) || (attribute.is_a?(Symbol) ? ha(attribute) : attribute)
        return name unless adapter
        search_params = (params[:q] || {}).to_h.with_indifferent_access
        attr_name = (options.delete(:column) || attribute).to_s
        default_order = options.delete :default_order

        existing_sort = adapter.sorts.detect { |s| s.name == attr_name }
        if existing_sort
          prev_attr, prev_dir = existing_sort.name, existing_sort.dir
          current_dir = prev_attr == attr_name ? prev_dir : nil
        else
          current_dir = nil
        end

        if current_dir
          new_dir = current_dir == 'desc' ? 'asc' : 'desc'
        else
          new_dir = default_order || 'asc'
        end

        html_options = options.delete(:html_options) || {}
        html_options[:class] = ['sort_link', current_dir, html_options[:class]].compact.join(' ')

        options.merge!(q: search_params.merge(s: "#{attr_name} #{new_dir}"), **collection_params)
        link_to [name, order_indicator_for(current_dir)].join(' ').html_safe, url_for(options), html_options
      end

      def order_indicator_for(order)
        if order == 'asc'
          '&#9650;'
        elsif order == 'desc'
          '&#9660;'
        else
          '<span class="order_indicator">&#9650;&#9660;</span>'
        end
      end

      def collection_params
        params.slice(:index_view, :view_options, *button_scopes.map(&:name)).permit!.to_h.symbolize_keys
      end

      def short_action_link(action, item)
        case action
          when :edit
            item_link_to_can? :update, item, icon('pencil', true), edit_resource_path(item), remote: settings[:list_edit],
                              class: 'btn btn-primary', title: t('admin.actions.edit.link')
          when :destroy
            item_link_to_can? :destroy, item, icon('trash', true), resource_path(item, return_to: request.url),
                              method: :delete, data: {confirm: t('admin.delete_confirmation')},
                              class: 'btn btn-danger', title: t('admin.actions.destroy.link')
          when :show
            item_link_to_can? :show, item, icon('info-sign', true), resource_path(item),
                              class: 'btn btn-info', title: t('admin.actions.show.link')
          when :preview
            preview_path = preview_resource_path(item)
            link_to(icon('eye-open', true), preview_path, class: 'btn btn-inverse', title: t('admin.actions.preview.link'), target: '_blank') if preview_path
          when :history
            item_link_to_can? :history, item, icon('book', true), history_resource_path(item),
                              class: 'btn btn-info', title: t('admin.actions.history.link')
          when AbAdmin::Config::ActionItem
            instance_exec(item, &action.data) if action.for_context?(self, item)
          else
            resource_action_link_method = "#{resource_instance_name}_short_action_link"
            list_link_method = "#{resource_instance_name}_#{action}_list_link"
            if respond_to?(list_link_method)
              send(list_link_method, item)
            elsif respond_to?(resource_action_link_method)
              send(resource_action_link_method, action, item)
            end
        end
      end

      def action_link(action)
        case action
          when :new
            link_to_can? :create, t('admin.actions.new.link'), new_resource_path, class: 'btn btn-primary new_resource', remote: settings[:list_edit]
          when :edit
            link_to_can? :update, t('admin.actions.edit.link'), edit_resource_path, class: 'btn btn-primary'
          when :destroy
            link_to_can? :destroy, t('admin.actions.destroy.link'), resource_path, method: :delete, data: {confirm: t('admin.delete_confirmation')},
                         class: 'btn btn-danger'
          when :show
            link_to_can? :show, t('admin.actions.show.link'), resource_path, class: 'btn btn-info'
          when :preview
            preview_path = preview_resource_path(resource)
            link_to(t('admin.actions.preview.link'), preview_path, class: 'btn btn-inverse', title: t('admin.actions.preview.link'), target: '_blank') if preview_path
          when :history
            link_to_can? :history, t('admin.actions.history.link'), history_resource_path, class: 'btn btn-info'
          when AbAdmin::Config::ActionItem
            instance_exec(&action.data) if action.for_context?(self)
          else
            resource_action_link_method = "#{resource_instance_name}_action_link"
            list_link_method = "#{resource_instance_name}_#{action}_link"
            if respond_to?(list_link_method)
              send(list_link_method)
            elsif respond_to?(resource_action_link_method)
              send(resource_action_link_method, action)
            end
        end
      end

      def preview_resource_path(item)
        return unless controller_name == 'manager' && manager.preview_path && option_conditions_met?(manager.preview_path[:options])
        manager.preview_path[:value].is_a?(Symbol) ? public_send(manager.preview_path[:value], item) : instance_exec(item, &manager.preview_path[:value])
      end

      def link_to_can?(act, *args, &block)
        subject = params[:id] ? resource : resource_class
        item_link_to_can?(act, subject, *args, &block)
      end

      def item_link_to_can?(act, item, *args, &block)
        if can?(act, item)
          if block_given?
            link_to(*args, &block)
          else
            link_to(*args)
          end
        end
      end

      def model_admin_menu_link(model)
        content_tag :li, class: ('active' if controller_name.split('/').last == model.model_name.plural) do
          link_to model.model_name.human(count: 9), "/admin/#{model.model_name.plural}"
        end
      end

      def admin_menu_link(name, path)
        content_tag :li, class: ('active' if path == request.path_info.split('/')[2]) do
          link_to name, "/admin/#{path}"
        end
      end

      def admin_menu_link_without_model(name, path, path_name)
        content_tag :li, class: ('active' if path_name == request.url.split('/').last) do
          link_to name, path
        end
      end

      def pagination_info(c)
        offset = c.offset
        total_entries = c.total_entries
        if total_entries.zero?
          t('will_paginate.pagination_info_empty')
        else
          t('will_paginate.pagination_info', from: offset + 1, to: [offset + settings[:per_page], total_entries].min, count: total_entries).html_safe
        end
      end

      def item_index_actions_panel(item)
        content = "#{item_index_actions(item)}#{capture{yield item} if block_given?}"
        <<-HTML.html_safe
          <td class="actions_panel">
            <div class="actions_panel-wrap_outer">
              <div class="actions_panel-wrap_inner">#{content}</div>
            </div>
          </td>
        HTML
      end

      def item_index_actions(item)
        actions = resource_action_items.map do |act|
          short_action_link(act, item)
        end
        actions << admin_comments_button(item) if settings[:comments] && settings[:comments][:list]
        actions.join(' ').html_safe
      end

      def admin_comments_button(item)
        title = [icon('comment', true), (item.admin_comments_count unless item.admin_comments_count.zero?)].compact.join(' ').html_safe
        link_to title, admin_admin_comments_path(resource_type: item.class.name, resource_id: item.id), remote: true,
                class: 'btn btn-info list_admin_comments_link'
      end

      def batch_action_toggle
        if settings[:batch]
          content_tag :th do
            check_box_tag '', '', false, id: nil, class: 'toggle'
          end
        end
      end

      def batch_action_item(item)
        if settings[:batch]
          content_tag :td do
            check_box_tag 'q[id_in][]', item.id, false, id: "batch_action_item_#{item.id}", class: 'batch_check'
          end
        end
      end

      def id_link(item, options={})
        options.reverse_merge!(edit: true, title: item.id)
        link_html = (options[:link_html] || {}).reverse_merge!(remote: settings[:list_edit], class: 'resource_id_link')
        if options[:edit] && can?(:edit, item)
          link_to options[:title], edit_resource_path(item), link_html
        elsif can?(:read, item)
          link_to options[:title], resource_path(item), link_html
        else
          options[:title]
        end
      end

      def auto_edit_link(record, options = {})
        return options[:missing] unless record
        return options[:title] || AbAdmin.display_name(record) if cannot?(:edit, record)
        admin_edit_link(record, options)
      end

      def auto_show_link(record, options = {})
        return options[:missing] unless record
        return options[:title] || AbAdmin.display_name(record) if cannot?(:read, record)
        admin_show_link(record, options)
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
        #url_options = {controller: record.class.model_name.plural, action: action, id: record.id}
        action_url_part = action == :show ? '' : "/#{action}"
        url = "/admin/#{record.class.model_name.plural}/#{record.id}#{action_url_part}"
        html_options = options.delete(:html_options) || {}
        link_to record_title, url, html_options
      end

    end
  end
end