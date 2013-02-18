class UserState < AbAdmin::Models::TypeModel
  self.codes = [:pending, :active, :suspended, :deleted]
  self.i18n_scope = [:admin, :user, :state]

  define_enum_by_codes
end
