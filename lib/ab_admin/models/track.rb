module AbAdmin
  module Models
    module Track

      extend ActiveSupport::Concern

      included do
        belongs_to :trackable, polymorphic: true
        belongs_to :owner, class_name: 'User'
        belongs_to :user, class_name: 'User'

        serialize :parameters, Hash
        serialize :trackable_changes, Hash

        before_create :make_trackable, if: :trackable

        class_attribute :tracking_enabled
        self.tracking_enabled = true

        alias_method :tracking_enabled?, :tracking_enabled

        scope :recently, -> { order('id DESC') }
      end

      module ClassMethods
        def import_from_batch_collection_action(tracks)
          tracks.each do |track|
            track.run_callbacks(:save) { false }
            track.run_callbacks(:create) { false }
          end
          ::Track.import(tracks)
        end
      end

      def action_title(params = {})
        parts = key.split('.')
        lookups = []
        if parts.length == 2
          lookups << [parts[0], 'actions', parts[1], 'title']
          lookups << [parts[0], 'actions', parts[1]]
          lookups << ['actions', parts[1], 'title']
        else
          lookups << ['actions', key, 'title']
          lookups << ['actions', key]
        end
        lookups.map!{|l| l.join('.').to_sym }
        lookups << key

        I18n.t(lookups.shift, (parameters.merge(params) || {}).merge(scope: :admin, default: lookups))
      end

      def trackable_changed_attrs
        return unless trackable
        trackable_changes.keys.map { |attr| trackable_han(attr) }.join(', ')
      end

      def trackable_han(attr)
        attr_s = attr.to_s
        trackable.class.han attr_s =~ /_ids$/ ? attr_s.sub(/_ids$/, '').pluralize : attr_s
      end

      private

      def make_trackable
        self.name ||= trackable.han.first(250)
        self.trackable_changes = trackable.changes.except(:updated_at)
      end

    end
  end
end
