class GenderType < AbAdmin::Models::TypeModel
  self.codes = [:male, :female, :undefined]
  self.i18n_scope = [:admin, :gender]

  define_enum_by_codes

end
