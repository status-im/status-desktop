#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file	test.feature
# *
# * \test	Status Desktop - Community
# * \date	January 2023
# **
# *****************************************************************************/

Feature: Status Desktop community navigation

    As an admin user I want to create a community and be able to leave it.

   	The feature start sequence is the following (setup on its own `bdd_hooks`):
    ** given A first time user lands on the status desktop and generates new key
    ** when user signs up with username "tester123" and password "TesTEr16843/!@00"
    ** and the user lands on the signed in app

    @mayfail
    Scenario Outline: User creates and leaves community
      # Create a community
      Given the user opens the community portal section
      And the user creates a community named "<community_name>", with description "My community description", intro "Community Intro" and outro "Community Outro"
      And the user lands on the community named "<community_name>"
      Then the count of communities in navbar is 1
      # Leave a community
      When the user opens app settings screen
      And the user opens the communities settings
      And the user leaves "<community_name>" community
      # Switch back to portal to ensure that leaving procedure finished
      When the user opens the community portal section
      Then the count of communities in navbar is 0
      Examples:
        | community_name |
        | My community 1 |
