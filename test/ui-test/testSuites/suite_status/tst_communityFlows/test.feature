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
        When the admin edits a community channel named <community_channel_name> to the name <new_community_channel_name>
        Then the user lands on the community channel named <new_community_channel_name>

        Examples:
        	| community_channel_name    | community_channel_description   | new_community_channel_name  |
            | test-channel    | Community channel description tested 1    | new-test-channel            |

