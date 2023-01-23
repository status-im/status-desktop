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

Feature: Status Desktop community members

    As a user I want to interact with members in a community


	@mayfail
	# TODO: It is throwing "RecursionError: maximum recursion depth exceeded" in `And the user opens the chat section
    Scenario: User invites a mutual contact
        Given the user starts the application with a specific data folder "../../../fixtures/mutual_contacts"
        When the user "tester123" logs in with password "TesTEr16843/!@00"
        Then the user lands on the signed in app
        Given the user opens the community portal section
        And the user lands on the community portal section
        And the user creates a community named "test_community", with description "Community description", intro "community intro" and outro "commmunity outro"
        Then the user lands on the community named "test_community"
        When the admin invites the user named Athletic to the community with message You are invited to my community
        And the user opens the chat section
        And the user switches to "Athletic" chat
        Then the last chat message contains "You are invited to my community"

    @mayfail
    # TODO this may fail because if we connect to the mailserver, we get the signal that Bob was already kicked out
    Scenario: User can kick a member
        Given the user starts the application with a specific data folder "../../../fixtures/community_members"
        When the user "Alice" logs in with password "TesTEr16843/!@00"
        Then the user lands on the signed in app
        When the user opens the community named "MyFriends"
        Then the user lands on the community named "MyFriends"
        When the admin kicks the user named Bobby
        And the admin goes back to the community
        Then the number of members is 1

    @relyon-mailserver
    # TODO we need the mailserver to get the message we want to reply to
    # TODO move this test to another Case that contains other community scenarios that need reboots
    Scenario Outline: The user can reply to another message
        # User 1 Bobby sends a message
        Given the user starts the application with a specific data folder "../../../fixtures/community_members"
        When the user "Bobby" logs in with password "TesTEr16843/!@00"
        Then the user lands on the signed in app
        When the user opens the community named "MyFriends"
        Then the user lands on the community named "MyFriends"
        When the user switches to "general" chat
        And the user sends a chat message "Reply to me please"
        Then the last chat message contains "Reply to me please"

        # User 2 Alice (admin) logs in
        Given the user restarts the app
        And the user "Alice" logs in with password "TesTEr16843/!@00"
        Then the user lands on the signed in app
        When the user opens the community named "MyFriends"
        Then the user lands on the community named "MyFriends"
        When the user replies to the message at index 0 with "<reply>"
        Then the chat message "<reply>" is displayed as a reply
        Examples:
         | reply           |
         | This is a reply |


