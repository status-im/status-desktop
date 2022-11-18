Feature: Status Desktop Chat Basic Flows

	As a user I want to join the public chat room "test" and do basic interactions.

    The following scenarios cover basic chat flows on "test" public channel.

    The feature start sequence is the following (setup on its own `bdd_hooks`):
    ** given A first time user lands on the status desktop and generates new key
    ** when user signs up with username "tester123" and password "TesTEr16843/!@00"
    ** and the user lands on the signed in app
    ** and user joins chat room "test"

	[Cleanup] Also each scenario starts with:
	** when the user opens the chat section
	# TODO: Add scenario end -> clear chat input.

    Scenario Outline: The user can chat in a public room
	     When the user sends a chat message "<message>"
		 Then the last chat message contains "<message>"
		 Examples:
		 | message  			 |
		 | Hello    			 |
		 | How are you    		 |
		 | I am from status   	 |
		 | tell me how you do?   |

    Scenario Outline: The user can reply to own message
         Given the user sends a chat message "<message>"
         When the user replies to the message at index 0 with "<reply>"
         Then the chat message "<reply>" is displayed as a reply of this user's "<message>"
         Examples:
     | message             | reply           |
     | random chat message | This is a reply |

    Scenario Outline: The user can edit a message
         Given the user sends a chat message "Edit me"
         When the user edits the message at index 0 and changes it to "<edited>"
         Then the chat message "<edited>" is displayed as an edited one
         Examples:
		 | edited		|
		 | Edited by me |

    @relyon-mailserver
    Scenario Outline: The user can reply to another message
         When the user replies to the message at index 0 with "<reply>"
         Then the chat message "<reply>" is displayed as a reply
         Examples:
		 | reply		   |
		 | This is a reply |


    Scenario Outline: The user can delete his/her own message
         Given the user sends a chat message "<message>"
         When the user deletes the message at index 0
         Then the last message displayed is not "<message>"
         Examples:
			 | message			   |
			 | random chat message |

    Scenario: The user can clear chat history
        Given the user sends a chat message "Hi hi"
        And the user sends a chat message "testing chat"
        And the user sends a chat message "history"
        When the user clears chat history
        Then the chat is cleared

	@mayfail
	# TODO: Verification of gif sent fails. And also `tenor GIFs preview is enabled` step doesn't work. Review it.
    Scenario: The user can send a GIF
        Given the user opens app settings screen
        And the user opens the messaging settings
        And tenor GIFs preview is enabled
        When the user sends a GIF message
        Then the GIF message is displayed

    @mayfail
	# TODO: It works standalone but when it runs as part of the sequence, the action of activates link preview doesn't work.
    Scenario Outline: The user can activate image unfurling
        Given the user sends a chat message "<image_url>"
		And the image "<image_url>" is not unfurled in the chat
		When the user opens app settings screen
		And the user opens the messaging settings
		And the user activates link preview
		And the user activates image unfurling
		And the user opens the chat section
		Then the image "<image_url>" is unfurled in the chat
        Examples:
           | image_url                                                                                      |
           | https://github.com/status-im/status-desktop/raw/master/test/ui-test/fixtures/images/doggo.jpeg |

    Scenario: The user is able to use emoji suggestions
        Given the user types "hello :thumbs"
		And the user selects the emoji in the suggestion's list
		When the user presses enter
		Then the last chat message contains "👍"

    @relyon-mailserver
    Scenario: The user cannot delete another user's message
         Then the user cannot delete the last message

   @relyon-mailserver
	Scenario Outline: The user can do a mention
		When the user inputs a mention to "<displayName>" with message "<message>"
		Then the "<displayName>" mention with message "<message>" have been sent
		Examples:
		| displayName | message          |
		| tester123   |  testing mention |

    @relyon-mailserver
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