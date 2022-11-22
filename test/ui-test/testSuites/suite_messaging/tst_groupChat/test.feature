Feature: Status Desktop Group Chat

	As a user I want to use group chat functionality.

	The feature start sequence follows the global one (setup on global `bdd_hooks`):

  Background:

    Given the user starts the application with a specific data folder "../../../fixtures/mutual_contacts"
    When the user "tester123" logs in with password "TesTEr16843/!@00"
    Then the user lands on the signed in app

 	Scenario Outline: As an admin user I want to create a group chat with my contacts and the invited users can send messages

		Given the user creates a group chat adding users
		   | Athletic |
		   | Nervous  |
		And the group chat is created
		And the group chat history contains "created the group" message
		And the group chat contains the following members
		   | Athletic |
		   | Nervous  |
		And the user opens the edit group chat popup
		And the user changes the group name to "<groupName>"
		And the user saves changes
		And the chat title is "<groupName>"

		When the user sends a chat message "<message1>"
		Then the chat title is "<groupName>"
		And the last chat message contains "<message1>"

		# Chat cleanup
		When the user leaves current chat
		Then the chat "<groupName>" does not exist

		# Invited user 1
		Given the user restarts the app
		And the user "Nervous" logs in with password "TesTEr16843/!@00"
		And the user lands on the signed in app
		And the user clicks on "<groupName>" chat
		When the user sends a chat message "<message2>"
		Then the last chat message contains "<message2>"

		# Chat cleanup
		When the user leaves chat "<groupName>" by right click on it
		Then the chat "<groupName>" does not exist

		# Invited user 2
		Given the user restarts the app
		And the user "Athletic" logs in with password "TesTEr16843/!@00"
		And the user lands on the signed in app
		And the user clicks on "<groupName>" chat
		When the user sends a chat message "<message3>"
		Then the last chat message contains "<message3>"

		# Chat cleanup
		When the user leaves chat "<groupName>" by right click on it
		Then the chat "<groupName>" does not exist

	    Examples:
		 | message1  			   | message2  			 		   | message3 					   | groupName	   |
		 | Admin user message sent | Invited user 1 message sent!! | Invited user 2 message sent!! | Here we are!! |