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

    The following scenarios cover basic flows of creating a community

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