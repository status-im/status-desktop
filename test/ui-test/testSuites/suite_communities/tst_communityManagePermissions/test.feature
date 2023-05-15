Feature: Community Permissions

Background:
	Given A first time user lands on the status desktop and generates new key
	And the user signs up with username "tester123" and password "TesTEr16843/!@00"
	And the user lands on the signed in app
	And the user opens the community portal section
    And the user lands on the community portal section
    And the user creates a community named "Test-Community", with description "My community description", intro "Community Intro" and outro "Community Outro"
    And the user lands on the community named "Test-Community"


 Scenario: Permissions welcome screen content validation
    When "Manage Community" is clicked in the community sidebar
    And "Permissions" section is selected
    Then the welcome "Permissions" image is present
    And the welcome "Permissions" title is present
    And the welcome "Permissions" subtitle is present
    And the welcome "Permissions" settings "<user onboarding checklist>" is present
   	| Give individual members access to private channels |
    | Monetise your community with subscriptions and fees |
    | Require holding a token or NFT to obtain exclusive membership rights |
    And "Add new permission" button is present