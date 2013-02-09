class StructureType < AbAdmin::Models::TypeModel
  self.codes = [:static_page, :posts, :main, :redirect, :group]
  self.i18n_scope = [:admin, :structure, :kind]

  define_enum_by_codes
end
