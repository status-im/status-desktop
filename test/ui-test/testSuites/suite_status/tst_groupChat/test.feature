Feature: Status Desktop Group Chat

	As a user I want to use group chat functionality.

  Background:

       Given the user starts the application with a specific data folder ../../../fixtures/group_chat

  	Scenario: As an admin user I want to create a group chat with my contacts and the invited users can send messages

  	    When the user tester123 logs in with password TesTEr16843/!@00
        Then the user lands on the signed in app
        When the user creates a group chat adding users
        	 | Athletic |
        	 | Nervous  |
		Then the group chat is created
		 And the group chat history contains "created the group" message
		 And the group chat title is Athletic&Nervous
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