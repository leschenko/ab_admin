@wip
Feature: Sign in
  In order to get access to protected sections of the site
  As a user
  I want to sign in

  Background:
    Given I am logged out

  Scenario: User do not exist
    Given I do not exist as a user
    When I sign in with valid credentials
    Then I see an invalid login message
    And I should be signed out

  Scenario: User enters wrong password
    Given I exist as a user
    When I sign in with a wrong password
    Then I see an invalid login message
    And I should be signed out

  Scenario: User signs in successfully
    Given I exist as a user
    When I sign in with valid credentials
    Then I see a successful sign in message
    And I should be on the dashboard page
    And I should see "Logout"
    And I should see my name
