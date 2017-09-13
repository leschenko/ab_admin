class StructureType < AbAdmin::Models::TypeModel
  self.codes = [:static_page, :posts, :main, :redirect, :group]
  self.i18n_scope = [:admin, :structure, :kind]

  define_enum_by_codes

  def has_static_page?
    static_page? || main?
  end
end
