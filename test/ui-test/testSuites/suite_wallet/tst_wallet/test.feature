Feature: Status Desktop Wallet

    As a user I want to use the wallet

   	The feature start sequence is the following (setup on its own `bdd_hooks`):

    ** given A first time user lands on the status desktop and generates new key
    ** when user signs up with username "tester123" and password "TesTEr16843/!@00"
    ** and the user lands on the signed in app

    ** given the user opens app settings screen
    ** and the user activates wallet and opens the wallet section
    ** and the user accepts the signing phrase

    Background: Navigation to main wallet screen

        Given the user opens wallet screen
        And the user clicks on the first account

	Scenario: The user can manage and observe a watch only account
        When the user adds watch only account "0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A" named "AccountWatch"
        Then the new account "AccountWatch" is added
		And the user has a positive balance of "ETH"
        And the user has a positive balance of "SNT"
        # And the collectibles are listed for the on
        # And the transactions are listed for the added account

    @mayfail
    # FIXME all wallet tests are broken. Issue #9498
    Scenario: The user imports a private key
        When an account named "AccountPrivate" is added via private key "8da4ef21b864d2cc526dbdb2a120bd2874c36c9d0a1fb7f8c63d7f7a8b41de8f" and authenticated using password "TesTEr16843/!@00"
        Then the new account "AccountPrivate" is added

    @mayfail
    # FIXME all wallet tests are broken. Issue #9498
	Scenario: The user generates a new account from wallet and deletes it
        When an account named "AccountGenerated" is generated and authenticated using password "TesTEr16843/!@00"
        Then the new account "AccountGenerated" is added
        When the user deletes the account "AccountGenerated" with password "TesTEr16843/!@00"
        Then the account "AccountGenerated" is not in the list of accounts

    @mayfail
    # FIXME all wallet tests are broken. Issue #9498
	Scenario: The user can import seed phrase
        When an account named "AccountSeed" is added via imported seed phrase "pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial" and authenticated using password "TesTEr16843/!@00"
        Then the new account "AccountSeed" is added

    @mayfail
    # FIXME all wallet tests are broken. Issue #9498
    Scenario: The user edits the default account
        Given the user opens app settings screen
        And the user opens the wallet settings
        When the user selects the default account
        And the user edits default account to "Default" name and "#FFCA0F" color
        Then the default account is updated to be named "DefaultStatus account" with color "#FFCA0F"

    @mayfail
    # FIXME all wallet tests are broken. Issue #9498
    Scenario Outline: The user can manage a saved address
        When the user adds a saved address named "<name>" and address "<address>"
        And the user toggles favourite for the saved address with name "<name>"
        Then the saved address "<name>" has favourite status "true"

        When the user deletes the saved address with name "<name>"
        Then the name "<name>" is not in the list of saved addresses

        When the user adds a saved address named "<name>" and address "<address>"
        And the user edits a saved address with name "<name>" to "<new_name>"
        Then the name "<new_name><name>" is in the list of saved addresses
    	Examples:
          | name | address                                    | new_name |
          | bar  | 0x8397bc3c5a60a1883174f722403d63a8833312b7 | foo      |