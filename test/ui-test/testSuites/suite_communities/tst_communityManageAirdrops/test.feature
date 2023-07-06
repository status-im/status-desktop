Feature: Community Airdrops

Background:
	Given A first time user lands on the status desktop and generates new key
	And the user signs up with username "tester123" and password "TesTEr16843/!@00"
	And the user lands on the signed in app
	And the user opens the community portal section
    And the user lands on the community portal section
    And the user creates a community named "Test-Community", with description "My community description", intro "Community Intro" and outro "Community Outro"
    And the user lands on the community named "Test-Community"


 Scenario: Airdrops welcome screen content validation
    When "Manage Community" is clicked in the community sidebar
    And "Airdrops" section is selected
    Then the welcome "Airdrops" image is present
    And the welcome "Airdrops" title is present
  	And the welcome "Airdrops" subtitle is present
    And the welcome "Airdrops" settings "<user onboarding checklist>" is present
    | Reward individual members with custom tokens for their contribution |
    | Incentivise joining, retention, moderation and desired behaviour |
    | Require holding a token or NFT to obtain exclusive membership rights |
    And "New Airdrop" button is disabled