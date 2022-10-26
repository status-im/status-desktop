Feature: Status Desktop Contacts Flows

    As a user I want to login the app and interact with contacts (add, remove, etc)

    Background: Sign up and open settings section
        Given A first time user lands on the status desktop and generates new key
        And the user signs up with username "tester123" and password "TesTEr16843/!@00"
        And the user lands on the signed in app
        And the user opens app settings screen


    Scenario: The user can add a contact with a chat key
    	When the user opens the messaging settings
    	And the user sends a contact request to the chat key "zQ3shQihZMmciZWUrjvsY6kUoaqSKp9DFSjMPRkkKGty3XCKZ" with the reason "I am a fellow tester"
        Then the contact request for chat key "zQ3shQihZMmciZWUrjvsY6kUoaqSKp9DFSjMPRkkKGty3XCKZ" is present in the pending requests tab
        # TODO for future improvements: log into the other account and check that we received the request (will require some cleanup)