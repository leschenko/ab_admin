# -*- encoding : utf-8 -*-
class UserRoleType < AbAdmin::Models::TypeModel
  self.codes = [:default, :redactor, :moderator, :admin]
  self.i18n_scope = [:admin, :user, :role]
end
