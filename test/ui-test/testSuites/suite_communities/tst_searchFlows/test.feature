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

    The feature start sequence is the following (setup on its own `bdd_hooks`):
    ** given A first time user lands on the status desktop and generates new key
    ** when user signs up with username "tester123" and password "TesTEr16843/!@00"
    ** and the user lands on the signed in app
    ** and user joins chat room "search-automation-test-1"
    ** and user joins chat room "search-automation-test-2"
    ** given the user opens the community portal section
    ** and the user lands on the community portal section
    ** and the user creates a community named "myCommunity", with description "My community description", intro "Community Intro" and outro "Commmunity outro"
    ** and the user lands on the community named "myCommunity"
    ** and the admin creates a community channel named "automation-community", with description "My description" with the method "bottom_menu"
    ** and the user lands on the channel named "automation-community"

	Background:
        # It starts opening the portal so that we see if the search really redirects
        Given the user opens the community portal section
        And the user lands on the community portal section

	@mayfail
	# myfail because of dekstop issue #7989. Once it is fixed, remove tag.
    Scenario: The user can search for a community channel
        Given the user opens the search menu
        And the user searches for "automation"
        When the user clicks on the search result for channel "automation-community"
        Then the channel named "automation-community" is open
