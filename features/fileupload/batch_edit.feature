@javascript
Feature: Batch edit images alt and title

  Background:
    Given I am logged in
    And I have avatar

  Scenario:
    Given I am on the edit profile page
    When I click image batch edit button
    Then I should see edit image meta form

    When I fill in image meta
    And I submit image meta form
    Then image should store meta