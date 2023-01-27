Feature: Status Desktop One to One Chat Flows

	As a user I want to do basic interactions in a one to one chat.

    The following scenarios cover one to one chat flows with mutual contacts

    The feature start sequence is the following (setup on its own `bdd_hooks`):
    ** given A first time user lands on the status desktop with the specific data folder "../../../fixtures/mutual_contacts"
    ** when user logins with username "tester123" and password "TesTEr16843/!@00"
    ** and the user lands on the signed in app

    [Cleanup] Also each scenario starts with:
    ** when the user opens the chat section

    [Cleanup] Also each scenario ends with:
    ** when the user leaves the current chat

    @mayfail
    # Fails on CI. Issue #9335
    Scenario: The user can create a one to chat
        When the user creates a one to one chat with "Athletic"
        Then the chat title is "Athletic"
        When the user sends a chat message "Test message"
        Then the last chat message contains "Test message"