# -*- encoding : utf-8 -*-
module AbAdmin
  module Models
    module Asset
      extend ActiveSupport::Concern

      included do
        belongs_to :user
        belongs_to :assetable, :polymorphic => true

        delegate :url, :original_filename, :to => :data
        alias :filename :original_filename
        #alias :size :data_file_size
        #alias :content_type :data_content_type
      end

      module ClassMethods
        def move_to(index, id)
          update_all(["sort_order = ?", index], ["id = ?", id.to_i])
        end
      end

      def thumb_url
        data.url(self.class.thumb_size) if image?
      end

      def format_created_at
        I18n.l(created_at, :format => "%d.%m.%Y %H:%M")
      end

      def as_json(options = nil)
        options = {
            :only => [:id, :guid, :assetable_id, :assetable_type, :user_id,
                      :data_file_size, :data_content_type, :is_main, :original_name],
            :root => 'asset',
            :methods => [:filename, :url, :preview_url, :thumb_url, :width, :height]
        }.merge(options || {})

        super
      end

      def has_dimensions?
        respond_to?(:width) && respond_to?(:height)
      end

      def image?
        AbAdmin::Utils.image_types.include?(self.data_content_type)
      end
    end
  end
end
