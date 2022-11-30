Feature: Status Desktop Chat Navigation

    As a user, I want the 1-1 and group chat navigation 
    to be ordered by chats that I was most recently active in first, 
    so that recent chats are easy to navigate to.

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

    Scenario: The user join chats and sees chats in reversed order
        Given the user has joined chats
        | first-chat  |
        | second-chat |
        | third-chat  |
        Then the user chats are sorted accordingly
        | third-chat  |
        | second-chat |
        | first-chat  |

    Scenario: After sending a message the user sees chats sorder by most recent activity
        Given the user has joined chats
        | first-chat  |
        | second-chat |
        | third-chat  |
        When the user switches to "second-chat" chat
        And the user sends a random chat message
        Then the random chat message is displayed
        And the user chats are sorted accordingly
        | second-chat |
        | third-chat  |
        | first-chat  |

