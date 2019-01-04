class RspecActiveModelBase
  include ActiveModel::AttributeMethods
  extend ActiveModel::Naming
  extend ActiveModel::Callbacks

  define_model_callbacks :commit

  attr_reader :attributes
  attr_accessor :id, :updated_at, :created_at

  class_attribute :primary_key, :base_class
  self.primary_key = :id
  self.base_class = self

  delegate :[], to: :attributes
  alias_method :_read_attribute, :[]

  def self.polymorphic_name
    name
  end

  def initialize(attributes = {})
    @id = attributes[:id]
    @attributes = attributes
  end

  def method_missing(id, *args, &block)
    attributes[id.to_sym] || attributes[id.to_s] || super
  end

  def new_record?
    false
  end

  def persisted?
    true
  end

  def save
    run_callbacks(:commit) {}
  end

  def destroy
    run_callbacks(:commit) { @destroyed = true }
  end

  def destroyed?
    !!@destroyed
  end

  def touch
    @updated_at = Time.current
  end
end
