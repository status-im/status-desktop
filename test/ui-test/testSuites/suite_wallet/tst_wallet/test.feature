Feature: Status Desktop Wallet

    As a user I want to use the wallet

    Background: Sign up & Enable wallet section
        Given A first time user lands on the status desktop and generates new key
        When user signs up with username tester123 and password TesTEr16843/!@00
        Then the user lands on the signed in app
        When the user opens app settings screen
        When the user activates wallet and opens the wallet section
        When the user accepts the signing phrase


	Scenario:  User can observe an account data
        When the user opens app settings screen
        And the user opens the wallet settings
        And the user toggles test networks
        And the user opens wallet screen
        And the user imports a seed phrase with one and TesTEr16843/!@00 and pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial
        Then the new account one is added
        And the user has a positive balance of ETH
        And the user has a positive balance of STT
        # And the collectibles are listed for the one
        And the transactions are listed for the added account


	Scenario: User can manage a list of accounts
        When the user adds watch only account with AccountWatch and 0x8397bc3c5a60a1883174f722403d63a8833312b7
        Then the new account AccountWatch is added
        When the user imports a private key with AccountPrivate and TesTEr16843/!@00 and 8da4ef21b864d2cc526dbdb2a120bd2874c36c9d0a1fb7f8c63d7f7a8b41de8f
        Then the new account AccountPrivate is added
        When the user imports a seed phrase with AccountSeed and TesTEr16843/!@00 and pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial
        Then the new account AccountSeed is added
        When the user generates a new account with AccountGenerated and TesTEr16843/!@00
        Then the new account AccountGenerated is added
        When the user deletes the account AccountGenerated
        Then the account AccountGenerated is not in the list of accounts
        When the user opens app settings screen
        And the user opens the wallet settings
        And the user selects the default account
        And the user edits default account to Default name and #FFCA0F color
        Then the new account with name DefaultStatus account and color #FFCA0F is updated


    Scenario Outline: User can manage a saved address
        When the user adds a saved address named <name> and address <address>
        And the user toggles favourite for the saved address with name <name>
        Then the saved address <name> has favourite status true
        When the user deletes the saved address with name <name>
        Then the name <name> is not in the list of saved addresses
        When the user adds a saved address named <name> and address <address>
        And the user edits a saved address with name <name> to <new_name>
        Then the name <new_name><name> is in the list of saved addresses

    	Examples:
          | name | address                                    | new_name |
          | bar  | 0x8397bc3c5a60a1883174f722403d63a8833312b7 | foo      |