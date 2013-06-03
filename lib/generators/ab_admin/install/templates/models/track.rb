class Track < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  belongs_to :owner, polymorphic: true
  belongs_to :user, polymorphic: true

  serialize :parameters, Hash
  serialize :changes, Hash

  attr_accessible :key, :name, :user, :owner, :trackable, :changes, :parameters

  before_create :make_trackable, if: :trackable?

  class_attribute :tracking_enabled
  self.tracking_enabled = true

  alias_method :tracking_enabled?, :tracking_enabled

  private

  def make_trackable
    self.name = trackable.han
    self.changes = trackable.new_changes
  end
end
