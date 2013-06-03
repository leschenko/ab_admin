class Track < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  belongs_to :owner, polymorphic: true
  belongs_to :user, polymorphic: true

  attr_accessible :key, :name, :user, :owner, :trackable, :trackable_changes, :parameters

  serialize :parameters, Hash
  serialize :trackable_changes, Hash

  before_create :make_trackable, if: :trackable

  class_attribute :tracking_enabled
  self.tracking_enabled = true

  alias_method :tracking_enabled?, :tracking_enabled

  def action_title(params = {})
    parts = key.split('.')
    lookups = []
    parts.length.times do
      lookups << "#{parts.join('.')}.title".to_sym
      lookups << parts.join('.').to_sym
      parts.shift
    end

    I18n.t(lookups.shift, (parameters.merge(params) || {}).merge(scope: [:admin, :actions], default: lookups))
  end

  private

  def make_trackable
    self.name ||= trackable.han
    self.trackable_changes ||= trackable.new_changes
  end
end
