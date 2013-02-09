class PositionType < AbAdmin::Models::TypeModel
  self.codes = [:default, :menu, :bottom]
  self.i18n_scope = [:admin, :structure, :position]

  define_enum_by_codes
end