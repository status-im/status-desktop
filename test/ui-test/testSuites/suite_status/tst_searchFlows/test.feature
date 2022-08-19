#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file   test.feature
# *
# * \test   Status Desktop - Search flows
# * \date   August 2022
# **
# *****************************************************************************/

Feature: Search feature (ctrl+F)

    As a user, I want to search the different chats and messages of the app

    Covers the search flows

    Background:
        Given A first time user lands on the status desktop and generates new key
        When user signs up with username tester123 and password TesTEr16843/!@00
        Then the user lands on the signed in app
        When user joins chat room search-automation-test-1
        And user joins chat room search-automation-test-2
        When the user opens the community portal section
        Then the user lands on the community portal section
        When the user creates a community named myCommunity, with description My community description, intro Community Intro and outro Community Outro
        Then the user lands on the community named myCommunity
        When the admin creates a community channel named automation-community, with description My description with the method bottom_menu
        Then the user lands on the channel named automation-community
        # Go back to the portal so that we see if the search really redirects
        When the user opens the community portal section

    Scenario: User can search for a community channel
        When the user opens the search menu
        And the user searches for automation
        And the user clicks on the search result for channel automation-community
        Then the user lands on the channel named automation-community

    Scenario: User can search for a public channel
        When the user opens the search menu
        And the user searches for automation
        And the user clicks on the search result for channel search-automation-test-2
        Then the chat title is search-automation-test-2

    Scenario: User can search for a message in a public channel
        When the user opens the chat section
        And user joins chat room search-automation-test-1
        Then the user is able to send  a random chat message
        # Go back to the portal so that we see if the search really redirects
        When the user opens the community portal section
        And the user opens the search menu
        And the user searches the random message
        Then the search menu shows 1 results
        When the user clicks on the search result for the random message
        Then the chat title is search-automation-test-1
