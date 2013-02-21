class AdminComment < ActiveRecord::Base
  attr_accessible :body, :resource_id, :resource_type

  belongs_to :resource, polymorphic: true
  belongs_to :author, class_name: 'User'
  belongs_to :user

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

  def for_form
    {body: body, id: id, author_name: user.try(:name), author_id: user.try(:id), created_at: I18n.l(created_at, format: :long)}
  end

end

