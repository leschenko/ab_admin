class ValidatorTestRecord
  include ActiveModel::Validations
  attr_accessor :email, :domain

  def initialize(attrs = {})
    attrs.each_pair { |k, v| send("#{k}=", v) }
  end
end
