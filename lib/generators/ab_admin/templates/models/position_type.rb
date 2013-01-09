# -*- encoding : utf-8 -*-
class PositionType
  include EnumField::DefineEnum

  def initialize(code)
    @code = code.to_sym
  end

  attr_reader :code

  define_enum do |builder|
    builder.member :default, :object => new("default")
    builder.member :menu, :object => new("menu")
    builder.member :bottom, :object => new("bottom")
  end

  def title
    I18n.t(@code, :scope => [:admin, :structure, :position])
  end

end
