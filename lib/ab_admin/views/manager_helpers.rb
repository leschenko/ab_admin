module AbAdmin
  module Views
    module ManagerHelpers

      def table_builder
        manager.table ||= ::AbAdmin::Config::Table.default_for_model(resource_class)
      end

      def search_builder
        manager.search ||= ::AbAdmin::Config::Search.default_for_model(resource_class)
      end

      def form_builder
        manager.form ||= ::AbAdmin::Config::Form.default_for_model(resource_class, :skip => [:id, :created_at, :updated_at, :lft, :rgt, :depth])
      end

      def show_builder
        manager.show ||= ::AbAdmin::Config::Show.default_for_model(resource_class)
      end
    end
  end
end
