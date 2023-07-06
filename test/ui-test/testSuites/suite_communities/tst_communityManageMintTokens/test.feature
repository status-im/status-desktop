Feature: Community Mint Tokens

Background:
	Given A first time user lands on the status desktop and generates new key
	And the user signs up with username "tester123" and password "TesTEr16843/!@00"
	And the user lands on the signed in app
	And the user opens the community portal section
    And the user lands on the community portal section
    And the user creates a community named "Test-Community", with description "My community description", intro "Community Intro" and outro "Community Outro"
    And the user lands on the community named "Test-Community"


 Scenario: Mint Tokens welcome screen content validation
    When "Manage Community" is clicked in the community sidebar
    And "Tokens" section is selected
    Then the welcome "Tokens" image is present
    And the welcome "Tokens" title is present
  	And the welcome "Tokens" subtitle is present
    And the welcome "Tokens" settings "<user onboarding checklist>" is present
    | Create remotely destructible soulbound tokens for admin permissions |
    | Reward individual members with custom tokens for their contribution |
    | Mint tokens for use with community and channel permissions |
    And "Mint token" button is disabled