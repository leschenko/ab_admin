# -*- encoding : utf-8 -*-
class StructureType
  include EnumField::DefineEnum

  attr_reader :kind

  def initialize(value)
    @kind = value
  end

  define_enum do |builder|
    [:static_page, :posts, :main, :redirect, :group].each do |kind|
      builder.member kind, :object => new(kind.to_s)
    end
  end

  def title
    I18n.t(@kind, :scope => [:admin, :structure, :kind])
  end

end
