class AdminComment < ActiveRecord::Base
  attr_accessible :user_id, :body, :resource_id, :resource_type

  belongs_to :resource, :polymorphic => true
  belongs_to :user

  validates_presence_of :resource
  validates_presence_of :body

  # @returns [String] The name of the record to use for the polymorphic relationship
  def self.resource_type(record)
    record.class.base_class.name.to_s
  end

  def self.find_for_resource(resource)
    where(:resource_type => resource_type(resource), :resource_id => resource.id)
  end

  def for_form
    {:author_full_name => user.try(:full_name), :author_id => user.try(:id), :body => body, :id => id,
     :created_at => I18n.l(created_at, :format => :long)}
  end
end

# == Schema Information
#
# Table name: admin_comments
#
#  id            :integer          not null, primary key
#  resource_id   :integer          not null
#  resource_type :string(255)      not null
#  body          :text
#  user_id       :integer
#  is_visible    :boolean          default(TRUE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

