Feature: Status Desktop One to One Chat Flows

	As a user I want to do basic interactions in a one to one chat.

  Background:

    Given the user starts the application with a specific data folder "../../../fixtures/mutual_contacts"
    When the user "tester123" logs in with password "TesTEr16843/!@00"
    Then the user lands on the signed in app

    Given the user starts the application with a specific data folder "../../../fixtures/mutual_contacts"
    When the user "Athletic" logs in with password "TesTEr16843/!@00"
    And the user lands on the signed in app

    Scenario: The user can create a one to chat
       	When the user maximizes the "1" application window
   		And the user opens the chat section
        When the user creates a one to one chat with "Athletic"
        Then the chat title is "Athletic"
        When the user sends a chat message "Test message"
        Then the last chat message contains "Test message"

        When the user maximizes the "2" application window
   		And the user opens the chat section
   		And the user wait for "tester123" chat and open it
   		Then the last chat message contains "Test message"

#    Scenario: After sending a message the user sees chats order by most recent activity
#        When the user creates a one to one chat with "Athletic"
#        And the user creates a one to one chat with "Nervous"
#        And the user switches to "Athletic" chat
#        And the user sends a random chat message
#        Then the random chat message is displayed
#        And the user chats are sorted accordingly
#        | Athletic |
#        | Nervous  |
