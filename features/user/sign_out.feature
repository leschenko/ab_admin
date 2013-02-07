Feature: Sign out
  To protect my account from unauthorized access
  Aa a signed in user
  I want to sign out

    Scenario: User signs out
      Given I am logged in
      When I sign out
      Then I should see a signed out message
      When I return to the site
      Then I should be signed out
