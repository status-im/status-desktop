Feature: Status Desktop Chat Navigation

    As a user I want to join seethe application reflect correctly
    when I navigate trough chats list.

    The feature start sequence is the following (setup on its own `bdd_hooks`):
    ** given A first time user lands on the status desktop and generates new key
    ** when user signs up with username "tester123" and password "TesTEr16843/!@00"
    ** and the user lands on the signed in app

	[Cleanup] Also each scenario starts with:
	** when the user opens the chat section

    Scenario: The user joins a room and marks it as read
        When the user joins chat room "test"
        And the user marks the channel "test" as read
        # TODO find a way to validate that it worked

    Scenario: The user sees chats sorted by most recent activity
        When the user joins chat room "first-chat"
        And the user joins chat room "second-chat"
        And the user joins chat room "third-chat"
        Then the user chats are sorted accordingly
        | third-chat  |
        | second-chat |
        | first-chat  |
        When the user switches to "second-chat" chat
        And the user sends a random chat message
        Then the random chat message is displayed
        And the user chats are sorted accordingly
        | second-chat |
        | third-chat  |
        | first-chat  |

