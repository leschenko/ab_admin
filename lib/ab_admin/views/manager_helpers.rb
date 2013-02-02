# -*- encoding : utf-8 -*-
module AbAdmin
  module Views
    module ManagerHelpers

      def export_builder
        manager.export ||= ::AbAdmin::Config::Export.default_for_model(resource_class)
      end

      def table_builder
        manager.table ||= ::AbAdmin::Config::Table.default_for_model(resource_class)
      end

      def search_builder
        manager.search ||= ::AbAdmin::Config::Search.default_for_model(resource_class)
      end

      def form_builder
        manager.form ||= ::AbAdmin::Config::Form.default_for_model(resource_class, :skip => [:created_at, :updated_at])
      end

    end
  end
end
