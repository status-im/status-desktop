#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file    test.feature
# *
# * \test    Status Desktop - Community Member Flows
# * \date    August 2022
# **
# *****************************************************************************/

Feature: Status Desktop community admin features

    As an admin I want to interact in a community

    @relyon-mailserver
    # TODO we need the mailserver to get the message we want to delete
    Scenario: Admin can delete another member's message
        # User 1 Bobby sends a message
        Given the user starts the application with a specific data folder "../../../fixtures/community_members"
        When the user "Bobby" logs in with password "TesTEr16843/!@00"
        Then the user lands on the signed in app
        When the user opens the community named "MyFriends"
        Then the user lands on the community named "MyFriends"
        When the user switches to "general" chat
        # Buffer message so that we are sure that once deleted, the last message will not be and old one
        And the user sends a chat message "Wholesome message"
        And the user sends a chat message "I sure hope no admin will delete this message"
        Then the last chat message contains "I sure hope no admin will delete this message"

        # User 2 Alice (admin) logs in
        Given the user restarts the app
        And the user "Alice" logs in with password "TesTEr16843/!@00"
        Then the user lands on the signed in app
        When the user opens the community named "MyFriends"
        Then the user lands on the community named "MyFriends"
        And the last chat message contains "I sure hope no admin will delete this message"

        # Deleting the message
        When the user deletes the message at index 0
        Then the last message displayed is not "I sure hope no admin will delete this message"


