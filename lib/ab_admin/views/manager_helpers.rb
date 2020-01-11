module AbAdmin
  module Views
    module ManagerHelpers
      INDEX_VIEW_ICONS = {table: 'list', tree: 'move', grid: 'th', chart: 'signal', map: 'map-marker'}

      def table_builder
        manager.table ||= ::AbAdmin::Config::Table.default_for_model(resource_class)
      end

      def search_builder
        manager.search ||= ::AbAdmin::Config::Search.default_for_model(resource_class)
      end

      def form_builder
        manager.form ||= ::AbAdmin::Config::Form.default_for_model(resource_class, skip: [:id, :created_at, :updated_at, :lft, :rgt, :depth])
      end

      def chart_builder
        manager.chart ||= ::AbAdmin::Config::Chart.default_for_model(resource_class)
      end

      def map_builder
        manager.map ||= ::AbAdmin::Config::Map.default_for_model(resource_class)
      end

      def modal_form_builder
        manager.modal_form ||= ::AbAdmin::Config::ModalForm.default_for_model(resource_class, skip: [:id, :created_at, :updated_at, :lft, :rgt, :depth])
      end

      def show_builder
        manager.show ||= ::AbAdmin::Config::Show.default_for_model(resource_class)
      end

      def table_item_field(item, field)
        if field.options[:editable] && field.data.is_a?(Symbol)
          if field.data.to_s.start_with?('is_')
            editable_bool(item, field.data)
          else
            admin_editable item, field.data, field.options[:editable]
          end
        elsif field.options[:image]
          item_image_link(item, assoc: field.name)
        else
          admin_pretty_data call_method_or_proc_on(item, field.data)
        end
      end

      def action_item_admin_path(name, record=nil)
        custom_action = manager.custom_action_for(name, self)
        if custom_action.collection?
          admin_collection_action_path(model_name: resource_collection_name, custom_action: custom_action.name)
        else
          record ||= resource
          admin_member_action_path(model_name: resource_collection_name, id: record.id, custom_action: custom_action.name)
        end
      end

      def index_view_link(index_view)
        options = {class: "btn #{('active' if settings[:current_index_view] == index_view)}", title: t("admin.index_view.#{index_view}", default: index_view.to_s)}
        url = url_for({index_view: index_view, q: params[:q]}.reject_blank)
        title = INDEX_VIEW_ICONS[index_view.to_sym] ? icon(INDEX_VIEW_ICONS[index_view.to_sym]) : index_view
        link_to title, url, options
      end
    end
  end
end
