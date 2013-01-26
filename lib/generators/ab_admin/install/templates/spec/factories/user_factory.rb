# encoding: utf-8
FactoryGirl.define do
  factory :user do
    email { generate(:email) }
    password '123456'
    password_confirmation '123456'
    confirmed_at 1.hour.ago
    trust_state UserState.active.id

    factory :inactive_user do
      trust_state UserState.suspended.id
    end

    factory :admin_user do
      user_role_id UserType.admin.id
    end

    factory :redactor_user do
      user_role_id UserType.redactor.id
    end

    factory :moderator_user do
      user_role_id UserType.moderator.id
    end
  end
end
