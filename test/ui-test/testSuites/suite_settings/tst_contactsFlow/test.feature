Feature: Status Desktop Contacts Flows

    As a user I want to login the app and interact with contacts (add, remove, etc)

    Background: Sign up and open settings section
        Given A first time user lands on the status desktop and generates new key
        And the user signs up with username "tester123" and password "TesTEr16843/!@00"
        And the user lands on the signed in app
        And the user opens app settings screen


	@mayfail
    Scenario: The user can add a contact with a chat key
    	When the user opens the messaging settings
    	And the user opens the contacts settings
    	And the user sends a contact request to the chat key "zQ3shQihZMmciZWUrjvsY6kUoaqSKp9DFSjMPRkkKGty3XCKZ" with the reason "I am a fellow tester"
        Then the contact request for chat key "zQ3shQihZMmciZWUrjvsY6kUoaqSKp9DFSjMPRkkKGty3XCKZ" is present in the pending requests tab
        # TODO for future improvements: log into the other account and check that we received the request (will require some cleanup)

    @relyon-mailserver @mayfail
    # FIXME this test will fail because we no longer support public channels. Re-implement in a community channel. Issue #9252
    Scenario: The user can add a contact from the chat
        # User 1 sends a message in the channel
        When the user opens the chat section
        And the user joins chat room "test-automation"
        And the user sends a chat message "I would like new friends"
        Then the last chat message contains "I would like new friends"

        # User 2 goes to the channel and sends a request from the profile popup
        Given the user restarts the app
        When the user lands on the status desktop and generates new key
        And the user signs up with username "tester2" and password "TesTEr16843/!@00"
        And the user lands on the signed in app
        And the user joins chat room "test-automation"
        # TODO remove when we have a reliable local mailserver
        And the user waits 2 seconds
        Then the last chat message contains "I would like new friends"
        When the user opens the user profile from the message at index 0
        And the user sends a contact request with the reason "I am a fellow tester"
        And the user closes the popup
        And the user opens app settings screen
        And the user opens the messaging settings
        And the user opens the contacts settings
        Then a contact request is present in the sent pending requests tab

        # Log back in with User 1 to see if we have the request
        Given the user restarts the app
        When the user "tester123" logs in with password "TesTEr16843/!@00"
        And the user lands on the signed in app
        And the user opens app settings screen
        And the user opens the messaging settings
        And the user opens the contacts settings
        Then a contact request is present in the received pending requests tab
