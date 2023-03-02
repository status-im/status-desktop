# This is a sample .feature file
# Squish feature files use the Gherkin language for describing features, a short example
# is given below. You can find a more extensive introduction to the Gherkin format at
# https://cucumber.io/docs/gherkin/reference/
Feature: Community Settings

Background:
	Given A first time user lands on the status desktop and generates new key
	And the user signs up with username "tester123" and password "TesTEr16843/!@00"
	And the user lands on the signed in app
	And the user opens the community portal section
    And the user lands on the community portal section
    And the user creates a community named "Test-Community", with description "My community description", intro "Community Intro" and outro "Community Outro"
    And the user lands on the community named "Test-Community"


 Scenario: Enable community permissions feature
   Given the user opens app settings screen
   And Application Settings "Advanced" is open
   And "Community Permissions Settings" is toggled on under Experimental features
   And the user opens the communities settings
   Then the user opens the community named "Test-Community"
   And the user lands on the community named "Test-Community"
   When "Manage Community" is clicked in the community sidebar
   Then "Permissions" should be an available option in Community Settings