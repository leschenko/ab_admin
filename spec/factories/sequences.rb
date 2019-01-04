FactoryBot.define do
  sequence(:email) { |n| Forgery::Email.address }

  sequence(:time) { |n| Time.now - n.hours }

  sequence(:date) { |n| Date.today - n.days }
end
