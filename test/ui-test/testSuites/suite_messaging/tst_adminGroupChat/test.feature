Feature: Status Desktop Group Chat

	As a group admin user I want to do some specific actions into the group chat

	The feature start sequence follows the global one (setup on global `bdd_hooks`):

  Background:

    Given the user starts the application with a specific data folder "../../../fixtures/mutual_contacts"
    When the user "tester123" logs in with password "TesTEr16843/!@00"
    Then the user lands on the signed in app

	When the user creates a group chat adding users
  	 | Athletic |
   	 | Nervous  |
   	Then the group chat is created

	@relyon-mailserver
	Scenario: As an admin user I want to change group chat's name, color, image and leave chat

		# As an admin user I want to change group chat's name
		Given the user opens the edit group chat popup
		And the user changes the group name to "Fat&Lazy"
		When the user saves changes
		Then the chat title is "Fat&Lazy"

		# As an admin user I want to change group chat's color
		Given the user opens the edit group chat popup
		And the user changes the group color to "#7CDA00"
		When the user saves changes
		Then the chat color is "#7CDA00"

		# As an admin user I want to change group chat's image
		Given the user opens the edit group chat popup
		And the user changes the group image
		When the user saves changes
		Then the chat image is changed

		# As an admin user I want to leave current chat
		When the user leaves current chat
		Then the chat "Fat&Lazy" does not exist

		# Cleanup other users chats:
		Given the user restarts the app
		And the user "Nervous" logs in with password "TesTEr16843/!@00"
		And the user lands on the signed in app
		When the user leaves chat "Fat&Lazy" by right click on it
		Then the chat "Fat&Lazy" does not exist

		Given the user restarts the app
		And the user "Athletic" logs in with password "TesTEr16843/!@00"
		And the user lands on the signed in app
		When the user leaves chat "Fat&Lazy" by right click on it
		Then the chat "Fat&Lazy" does not exist

