# encoding: utf-8
FactoryGirl.define do
  factory :user do
    email { generate(:email) }
    password '123456'
    password_confirmation '123456'

    factory :default_user do
      confirmed_at 1.hour.ago
      trust_state UserState.active.id
      first_name Forgery::Name.first_name
      last_name Forgery::Name.last_name

      factory :admin_user do
        user_role_id UserRoleType.admin.id
      end

      factory :redactor_user do
        user_role_id UserRoleType.redactor.id
      end

      factory :moderator_user do
        user_role_id UserRoleType.moderator.id
      end

      factory :inactive_user do
        trust_state UserState.suspended.id
      end
    end
  end
end
