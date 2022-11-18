Feature: Status Desktop Chat Navigation

    Scenario: The user joins a room and marks it as read
        When the user joins chat room "test"
        And the user marks the channel "test" as read
        # TODO find a way to validate that it worked

    @merge
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

