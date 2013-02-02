Feature: Edit User
  As a registered user of the website
  I want to edit my user profile
  so I can change my username

    Scenario: I sign in and edit my account
      Given I am logged in
      When I edit my account details
      Then I should see an account edited message
      And I should see my name in sidebar

#    Scenario: I sign in and edit my account
#      Given I am logged in
#      When I follow "Кабинет"
#      And I follow "Редактировать"
#      And I fill in "Имя" with "Bob"
#      And I fill in "Фамилия" with "Nelson"
#      And I press "Сохранить"
#      Then I should be on Bob's profile page
