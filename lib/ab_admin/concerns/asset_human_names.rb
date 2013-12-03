module AbAdmin
  module Concerns
    module AssetHumanNames
      extend ActiveSupport::Concern

      module ClassMethods
        def asset_human_names(*args)
          class_attribute :asset_human_names_list, instance_writer: false
          after_save :make_asset_human_names
          self.asset_human_names_list = args
        end
      end

      def make_asset_human_names
        asset_human_names_list.each do |assoc|
          Array(send(assoc)).each do |asset|
            asset.data.store_model_filename
          end
        end
      end
    end
  end
end
