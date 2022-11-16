#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file    test.feature
# *
# * \test    Status Desktop - Community Chat Flows
# * \date    July 2022
# **
# *****************************************************************************/

Feature: Status Desktop community messages

    As a user I want to send messages and interact with channels in a community

 	The feature start sequence is the following (setup on its own `bdd_hooks`):
    ** given A first time user lands on the status desktop and generates new key
    ** when user signs up with username "tester123" and password "TesTEr16843/!@00"
    ** and the user lands on the signed in app

    Background:
        Given the user opens the community portal section
        And the user lands on the community portal section
        And the user creates a community named "test_community", with description "Community description", intro "community intro" and outro "commmunity outro"
        Then the user lands on the community named "test_community"

    Scenario: The user sends a test image
        When the user sends a test image in the current channel
        Then the last chat message contains the test image

    Scenario: The user sends a test image with a message
        When the user sends a test image in the current channel with message "Message" with an image
        Then the test image is displayed just before the last message
        And the last chat message contains "Message"

    Scenario: The user sends multiple test images with a message
        When the user sends multiple test images in the current channel with message "Message" with an image again
        Then the test images are displayed just before the last message
        And the last chat message contains "Message"

    Scenario: The user pins and unpins messages
        # This one wont work until #6554 is fixed
        # And the amount of pinned messages is 0
		Given the user sends a chat message "Message 1"
        When the user pins the message at index 0
        Then the amount of pinned messages is 1

        Given the user sends a chat message "Message 2"
        When the user pins the message at index 0
        Then the amount of pinned messages is 2

        When the user unpins the message at index 0
        Then the amount of pinned messages is 1