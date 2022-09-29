Feature: Status Desktop Group Chat

	As a user I want to use group chat functionality.

  Background:

    Given the user starts the application with a specific data folder ../../../fixtures/group_chat
    When the user tester123 logs in with password TesTEr16843/!@00
    Then the user lands on the signed in app

 	Scenario: As an admin user I want to create a group chat with my contacts and the invited users can send messages

       When the user creates a group chat adding users
       	 | Athletic |
      	 | Nervous  |
	   Then the group chat is created
		And the group chat history contains "created the group" message
		And the chat title is Athletic&Nervous
		And the group chat contains the following members
       	 | Athletic |
       	 | Nervous  |
		And the group chat is up to chat sending "Admin user message sent" message

		# Invited user 1
		When the user restarts the app
		 And the user Nervous logs in with password TesTEr16843/!@00
	    Then the user lands on the signed in app
	    When the user clicks on Athletic&Nervous chat
	    Then the group chat is up to chat sending "Invited user 1 message sent!!" message

	    # Invited user 2
		When the user restarts the app
		 And the user Athletic logs in with password TesTEr16843/!@00
	    Then the user lands on the signed in app
	    When the user clicks on Athletic&Nervous chat
	    Then the group chat is up to chat sending "Invited user 2 message sent!!" message

	    # TODO: Add cleanup scenario. Leave, one by one, the chat

	@mayfail @merge
	Scenario: As an admin user I want to change group chat's name, color and image
		When the user creates a group chat adding users
      	 | Athletic |
       	 | Nervous  |
       	Then the group chat is created

		When the user opens the edit group chat popup
		 And the user changes the group name to Fat&Lazy
		 And the user saves changes
		Then the chat title is Fat&Lazy

		When the user opens the edit group chat popup
		 And the user changes the group color to #7CDA00
		 And the user saves changes
		Then the chat color is #7CDA00

		When the user opens the edit group chat popup
		 And the user changes the group image
		 And the user saves changes
		Then the chat image is changed

		When the user leaves current chat
		 Then chat Fat&Lazy does not exist
