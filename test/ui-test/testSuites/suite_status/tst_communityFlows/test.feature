#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file	test.feature
# *
# * \test	Status Desktop - Community
# * \date	July 2022
# **
# *****************************************************************************/

Feature: Status Desktop community

    As a user I want to create a community and chat

    The following scenarios cover basic flows of a community

    Background:
        Given A first time user lands on the status desktop and generates new key
        When user signs up with username tester123 and password TesTEr16843/!@00
        Then the user lands on the signed in app
        Then the user opens the community portal section
        Then the user lands on the community portal section

    Scenario Outline: User creates a community
        When the user creates a community named <community_name>, with description <community_description>, intro <community_intro> and outro <community_outro>
        Then the user lands on the community named <community_name>

        Examples:
            | community_name    | community_description   | community_intro  | community_outro  |
            | testCommunity1    | Community tested 1      | My intro for the community | My community outro  |


    Scenario Outline: Admin creates a community channel
        When the user creates a community named myCommunity, with description My community description, intro Community Intro and outro Community Outro
        Then the user lands on the community named myCommunity
        When the admin creates a community channel named <community_channel_name>, with description <community_channel_description> with the method <method>
        Then the user lands on the community channel named <community_channel_name>

        Examples:
        	| community_channel_name    | community_channel_description     | method           |
        	| test-channel    | Community channel description tested 1      | bottom_menu      |
            | test-channel2   | Community channel description tested 2      | right_click_menu |

    Scenario Outline: Admin edits a community channel
        When the user creates a community named myCommunity, with description My community description, intro Community Intro and outro Community Outro
        Then the user lands on the community named myCommunity
        When the admin creates a community channel named test-channel, with description My description with the method bottom_menu
        Then the user lands on the community channel named test-channel
        When the admin edits the current community channel to the name <new_community_channel_name>
        Then the user lands on the community channel named <new_community_channel_name>

        Examples:
        	| community_channel_name    | community_channel_description   | new_community_channel_name  |
            | test-channel    | Community channel description tested 1    | new-test-channel            |

    Scenario Outline: Admin edits a community
        When the user creates a community named myCommunity, with description My community description, intro Community Intro and outro Community Outro
        Then the user lands on the community named myCommunity
        When the admin edits the current community to the name <new_community_name> and description <new_community_description> and color <new_community_color>
        When the admin goes back to the community
        Then the user lands on the community named <new_community_name>

        Examples:
            | new_community_name       | new_community_description  | new_community_color |
            | myCommunityNamedChanged  | Cool new description 123   | #ff0000             |

    Scenario: Admin deletes a community channel
        When the user creates a community named myCommunity, with description My community description, intro Community Intro and outro Community Outro
        Then the user lands on the community named myCommunity
        When the admin creates a community channel named test-channel, with description My description with the method bottom_menu
        Then the user lands on the community channel named test-channel
        And the channel count is 2
        When the admin deletes current channel
        Then the channel count is 1

    Scenario: User leaves community
        When the user creates a community named testCommunity, with description My community description, intro Community Intro and outro Community Outro
        Then the user lands on the community named testCommunity
        When the user opens app settings screen
        And the user opens the communities settings
        And the user leaves the community
        Then the count of communities in navbar is 0

    Scenario Outline: User changes the emoji of a channel
        When the user creates a community named myCommunity, with description My community description, intro Community Intro and outro Community Outro
        Then the user lands on the community named myCommunity
        When the admin creates a community channel named test-channel, with description My description with the method bottom_menu
        Then the user lands on the community channel named test-channel
        When the user changes emoji of the current community channel with emoji by description <new_emoji_description>
        Then the community channel has emoji <new_emoji>

        Examples:
            | new_emoji_description | new_emoji |
            | thumbs up             | 👍        |
