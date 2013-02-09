class StaticPageType < AbAdmin::Models::TypeModel
  self.codes = [:default, :pictures, :video]
  self.i18n_scope = [:admin, :post, :kind]

  define_enum_by_codes
end