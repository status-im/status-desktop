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

    As an admin user I want to create a community and do some action in the community

    The following scenarios cover basic flows of a community

 	The feature start sequence is the following (setup on its own `bdd_hooks`):
    ** given A first time user lands on the status desktop and generates new key
    ** when user signs up with username "tester123" and password "TesTEr16843/!@00"
    ** and the user lands on the signed in app

    Background:
        Given the user opens the community portal section
        And the user lands on the community portal section
        And the user creates a community named "myCommunity", with description "My community description", intro "Community Intro" and outro "Community Outro"
        And the user lands on the community named "myCommunity"

    Scenario Outline: The admin creates a community channel
        When the admin creates a community channel named "<community_channel_name>", with description "<community_channel_description>", with the method "<method>"
        Then "<community_channel_name>" should be in the list of uncategorized channels
        And the channel named "<community_channel_name>" is open
        Examples:
            | community_channel_name    | community_channel_description     | method           |
            | test-channel    | Community channel description tested 1      | bottom_menu      |
            | test-channel2   | Community channel description tested 2      | right_click_menu |

    Scenario Outline: The admin edits a community channel
        Given the admin creates a community channel named "<community_channel_name>", with description "<community_channel_description>", with the method "bottom_menu"
        And the channel named "<community_channel_name>" is open
        When the admin edits the current community channel to the name "<new_community_channel_name>"
        Then the channel named "<new_community_channel_name>" is open
        Examples:
            | community_channel_name | community_channel_description   		  | new_community_channel_name  |
            | test-channel    		 | Community channel description tested 1 | new-test-channel            |

    Scenario: The admin deletes a community channel
        Given the admin creates a community channel named "test-channel2", with description "My description", with the method "bottom_menu"
        And the channel named "test-channel2" is open
        And the channel count is 2
        When the admin deletes current channel
        Then the channel count is 1

    Scenario Outline: The admin creates a community category
        Given the admin creates a community channel named "<channel_name>", with description "Some description", with the method "<method>"
        When the admin creates a community category named "<category_name>", with channels "<channel_name>" and with the method "<method>"
        Then the category named "<category_name>" contains channels "<channel_name>"
        Examples:
            | channel_name   | category_name   | method           |
            | test-channel-1 | test-category-1 | bottom_menu      |
            | test-channel-2 | test-category-2 | right_click_menu |

    Scenario: The admin edits a community category
        Given the admin creates a community channel named "test-channel", with description "My description", with the method "bottom_menu"
        And the admin creates a community category named "test-category", with channels "test-channel" and with the method "bottom_menu"
        And the category named "test-category" contains channels "test-channel"
        When the admin renames the category "test-category" to "new-test-category" and toggles the channels "test-channel, general"
        Then the category named "new-test-category" contains channels "general"
        And the category named "test-category" is missing

    Scenario: The admin deletes a community category
        Given the admin creates a community channel named "test-channel", with description "My description", with the method "bottom_menu"
        And the admin creates a community category named "test-category", with channels "test-channel" and with the method "bottom_menu"
        And the category named "test-category" contains channels "test-channel"
        When the admin deletes category named "test-category"
        Then the category named "test-category" is missing

    Scenario Outline: The admin edits a community name, description and color separately
        When the admin changes the community name to "<new_community_name>"
        Then the community overview name is "<new_community_name>"
        When the admin goes back to the community
        And the admin changes the community description to "<new_community_description>"
        Then the community overview description is "<new_community_description>"
        When the admin goes back to the community
        And the admin changes the community color to "<new_community_color>"
        Then the community overview color is "<new_community_color>"
        Examples:
            | new_community_name       | new_community_description  | new_community_color |
            | myCommunityNamedChanged  | Cool new description 123   | #ff0000             |

    Scenario Outline: The admin changes the emoji of a channel
        When the admin changes the current community channel emoji to "<new_emoji_description>"
        Then the community channel has emoji "<new_emoji>"
        Examples:
            | new_emoji_description | new_emoji |
            | thumbs up             | 👍        |

    # TODO: This scenario must be in a different feature since it does not accomplishe the start/en sequence and / or background
    # Add new test case that contains scenarios related to create/delete and navigate throw communities and usage of navbar.
    #@merge
    #Scenario: User leaves community
    #    When the user opens app settings screen
    #    And the user opens the communities settings
    #    And the user leaves the community
    #    Then the count of communities in navbar is 0
