module AbAdmin
  module Models
    module AdminComment
      extend ActiveSupport::Concern

      included do
        belongs_to :resource, polymorphic: true
        belongs_to :resource_user, class_name: 'User'
        belongs_to :user

        has_many :attachment_files, as: :assetable, dependent: :destroy

        validates_presence_of :resource
        validates_presence_of :body

        before_save :set_user_name, :set_resource_user
        after_create :increment_counter_cache
        before_destroy :decrement_counter_cache

        scope :admin, proc { includes(:user, :attachment_files) }
        
        fileuploads :attachment_files
      end

      module ClassMethods
        def resource_type(record)
          record.class.base_class.name.to_s
        end

        def find_for_resource(resource)
          where(resource_type: resource_type(resource), resource_id: resource.id).includes(:attachment_files)
        end

        def find_resource(resource_type, resource_id)
          resource_type.constantize.find(resource_id)
        end
      end

      def set_user_name
        self.user_name = user.name.presence || user.email
        true
      end

      def set_resource_user
        self.resource_user = resource.try(:user) if resource.respond_to?(:user)
        true
      end

      def for_form
        {id: id, body: body, user_name: user.try(:name), user_id: user.try(:id), created_at: I18n.l(created_at, format: :long)}
      end

      def increment_counter_cache
        resource.increment!(:admin_comments_count) if resource_counter_cache?
        true
      end

      def decrement_counter_cache
        resource.decrement!(:admin_comments_count) if resource_counter_cache?
        true
      end

      def resource_counter_cache?
        resource.class.column_names.include?('admin_comments_count')
      end
    end
  end
end
