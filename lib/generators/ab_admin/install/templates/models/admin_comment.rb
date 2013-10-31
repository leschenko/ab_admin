class AdminComment < ActiveRecord::Base
  attr_accessible :body, :resource_id, :resource_type

  belongs_to :resource, polymorphic: true
  belongs_to :author, class_name: 'User'
  belongs_to :user

  has_many :attachment_files, as: :assetable, dependent: :destroy
  fileuploads :attachment_files

  after_create :increment_counter_cache
  before_destroy :decrement_counter_cache

  scope :admin, includes(:author, :attachment_files)

  validates_presence_of :resource
  validates_presence_of :body

  def set_author(user)
    return unless user
    self.author_id = user.id
    self.author_name = user.name.presence || user.email
  end

  def self.resource_type(record)
    record.class.base_class.name.to_s
  end

  def self.find_for_resource(resource)
    where(resource_type: resource_type(resource), resource_id: resource.id)
  end

  def self.find_resource(resource_type, resource_id)
    resource_type.constantize.find(resource_id)
  end

  def for_form
    {body: body, id: id, author_name: user.try(:name), author_id: user.try(:id), created_at: I18n.l(created_at, format: :long)}
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

