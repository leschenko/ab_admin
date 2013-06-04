module AbAdmin
  module Concerns
    module HasTracking
      extend ActiveSupport::Concern

      included do
        has_many :tracks, as: :trackable
        class_attribute :tracking_enabled
        self.tracking_enabled = true
      end

      def track(options={})
        return unless tracking_enabled?
        options[:trackable] ||= self
        options[:owner] ||= user if respond_to?(:user)
        options[:user] ||= updater if respond_to?(:updater)
        options[:key] = [self.class.model_name.plural, options[:key]].compact.join('.')
        tracks.build(options)
      end

      module ClassMethods
        def tracking_enabled?
          tracking_enabled && Activity.tracking_enabled
        end
      end
    end
  end
end