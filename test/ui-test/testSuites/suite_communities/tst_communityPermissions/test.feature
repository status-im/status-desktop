
Feature: Community Permissions

Background:

	Given A first time user lands on the status desktop and generates new key
	And the user signs up with username "tester123" and password "TesTEr16843/!@00"
	And the user lands on the signed in app
	And the user opens the community portal section
    And the user lands on the community portal section
    And the user creates a community named "Test-Community", with description "My community description", intro "Community Intro" and outro "Community Outro"
    And the user lands on the community named "Test-Community"

	And the user opens app settings screen
	And Application Settings "Advanced" is open
	And "Community Permissions Settings" is toggled on under Experimental features
	And the user opens the communities settings
	And the user opens the community named "Test-Community"
	And the user lands on the community named "Test-Community"
	And "Manage Community" is clicked in the community sidebar
	And "Permissions" should be an available option in Community Settings

Scenario: Welcome Permissions Screen
    Given "Permissions" section is selected
    Then "Permissions" title is displayed


