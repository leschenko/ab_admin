# -*- encoding : utf-8 -*-
class UserState
  include EnumField::DefineEnum
  def initialize(code)
    @code = code.to_sym
  end

  define_enum do |builder|
    builder.member :pending, :object => new("pending")
    builder.member :active, :object => new("active")
    builder.member :suspended, :object => new("suspended")
    builder.member :deleted, :object => new("deleted")
  end

  attr_reader :code

  def title
    I18n.t(@code, :scope => [:admin, :user, :state])
  end
end
