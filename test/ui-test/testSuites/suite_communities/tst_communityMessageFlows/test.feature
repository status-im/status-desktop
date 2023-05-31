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

	@mayfail
	# TODO: Verification is broken.
    Scenario: The user sends a test image
        When the user sends a test image in the current channel
        Then the last chat message contains the test image

	@mayfail
	# TODO: Verification is broken.
    Scenario: The user sends a test image with a message
        When the user sends a test image in the current channel with message "Message" with an image
        Then the test image is displayed just before the last message
        And the last chat message contains "Message"

	@mayfail
	# TODO: Verification is broken.
    Scenario: The user sends multiple test images with a message
        When the user sends multiple test images in the current channel with message "Message" with an image again
        Then the test images are displayed just before the last message
        And the last chat message contains "Message"

	@mayfail
	# TODO: It is unstable. Needs to be checked.
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

    Scenario Outline: The user can reply to own message
        Given the user sends a chat message "<message>"
        When the user replies to community chat message at index 0 with "<reply>"
        Then the chat message "<reply>" is displayed as a reply of this user's "<message>"
        Examples:
        | message                | reply           |
        | Community chat message | This is a reply |

	@mayfail
    Scenario Outline: The user can edit a message
        Given the user sends a chat message "Edit me"
        # Checking that message can be edited several times
        When the user edits the message at index 0 and changes it to "first edition"
        Then the chat message "first edition" is displayed as an edited one
        When the user edits the message at index 0 and changes it to "<edited>"
        Then the chat message "<edited>" is displayed as an edited one
        Examples:
        | edited       |
        | Edited by me |

    Scenario Outline: The user can delete his/her own message
         Given the user sends a chat message "<message>"
         When the user deletes the message at index 0
         Then the last message displayed is not "<message>"
         Examples:
             | message             |
             | random chat message |

	@mayfail
    Scenario: The user can clear chat history
        Given the user sends a chat message "Hi hi"
        And the user sends a chat message "testing chat"
        And the user sends a chat message "history"
        When the user clears chat history
        Then the chat is cleared

    Scenario: The user can send a GIF
        Given the user opens app settings screen
        And the user opens the messaging settings
        When the user activates the link preview if it is deactivated
        And the user activates tenor GIFs preview
        And the user opens the community named "test_community"
        Then the user lands on the community named "test_community"
        When the user sends a GIF message
        Then the GIF message is displayed

    @mayfail
    # Test fails at finding the link. Issue #9380
    Scenario Outline: The user can activate image unfurling
        Given the user sends a chat message "<image_url>"
        And the image "<image_url>" is not unfurled in the chat
        And the user opens app settings screen
        And the user opens the messaging settings
        When the user activates the link preview if it is deactivated
        And the user activates image unfurling
        And the user opens the community named "test_community"
        Then the user lands on the community named "test_community"
        When the user switches to "general" chat
        Then the image "<image_url>" is unfurled in the chat
        Examples:
           | image_url                                                                                      |
           | https://github.com/status-im/status-desktop/raw/master/test/ui-test/fixtures/images/doggo.jpeg |

   Scenario: The user is able to use emoji suggestions
        Given the user types "hello :thumbs"
        And the user selects the emoji in the suggestion's list
        When the user presses enter
        Then the last chat message contains "👍"

    @mayfail
    # This tests fails. Issue #9314
    Scenario Outline: The user can do a mention
        When the user inputs a mention to "<displayName>" with message "<message>"
        Then the "<displayName>" mention with message "<message>" have been sent
        Examples:
        | displayName | message          |
        | tester123   |  testing mention |

    Scenario Outline: The user can not do a mention to a not existing users
        Then the user cannot input a mention to a not existing user "<displayName>"
        Examples:
        | displayName        |
        | notExistingAccount |
        | asdfgNoNo          |

    Scenario: The user can send an emoji as a message
        When the user sends the emoji "heart_eyes" as a message
        Then the last chat message contains "😍"

    Scenario Outline: The user can send an emoji in a message
        When the user sends the emoji "sunglasses" with message "<message>"
        Then the last chat message contains "😎"
        And the last chat message contains "<message>"
        Examples:
         | message          |
         | wow I'm so cool  |

    Scenario: The user can type message with emoji autoreplace
        When the user sends a chat message "Hello :)"
        Then the last chat message contains "🙂"
        And the last chat message contains "Hello"

    @mayfail
    # NOTE: It may be flaky due to undeterministic network conditions and 3rd party infura response.
    Scenario: The user can send a sticker after installing a free pack
         Given the user installs the sticker pack at position 4
         When the user sends the sticker at position 2 in the list
         Then the last chat message is a sticker

	@mayfail
    Scenario: The user marks a channel as read
        When the user marks the channel "general" as read
        # TODO find a way to validate that it worked
