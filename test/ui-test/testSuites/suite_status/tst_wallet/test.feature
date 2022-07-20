Feature: Status Desktop Wallet

    As a user I want to use the wallet

    Background: Sign up & Enable wallet section
    	Given A first time user lands on the status desktop and generates new key
    	When user signs up with username tester123 and password TesTEr16843/!@00
    	Then the user lands on the signed in app
    	When the user opens app settings screen
        When the user activates wallet and opens the wallet section
        When the user accept the signing phrase

    Scenario Outline: User add a watch only account
        When the user add watch only account with <account_name> and <address>
        Then the new account <account_name> is added

    	Examples:
      	  | account_name | address 										|
      	  | one		     | 0x8397bc3c5a60a1883174f722403d63a8833312b7   |
      	  | two		     | 0xf51ba8631618b9b3521ff4eb9adfd8a837455226   |


    Scenario Outline: User generate a new account from wallet
        When the user generate a new account with <account_name> and TesTEr16843/!@00
        Then the new account <account_name> is added

    	Examples:
      	  | account_name |
      	  | one		     |
    	  | two		     |

  	Scenario Outline: User import a private key
        When the user import a private key with <account_name> and TesTEr16843/!@00 and <private_key>
        Then the new account <account_name> is added

    	Examples:
      	  | account_name | private_key |
      	  | one		     | 8da4ef21b864d2cc526dbdb2a120bd2874c36c9d0a1fb7f8c63d7f7a8b41de8f |

	Scenario Outline: User import a seed phrase
        When the user import a seed phrase with <account_name> and TesTEr16843/!@00 and <seed_phrase>
        Then the new account <account_name> is added

    	Examples:
      	  | account_name | seed_phrase |
      	  | one		     | indoor dish desk flag debris potato excuse depart ticket judge file exit |

 	Scenario Outline: User delete a generated account
        When the user generate a new account with <account_name> and TesTEr16843/!@00
        And the user deletes the account <account_name>
        Then the account <account_name> is not in the list of accounts

    	Examples:
      	  | account_name |
      	  | one		     |