Feature: Settings -> Wallet


    Background:
        Given A first time user lands on the status desktop and generates new key
        And the user signs up with username "tester123" and password "TesTEr16843/!@00"
        And the user lands on the signed in app
        And the user opens the wallet section
        And the user accepts the signing phrase

    @mayfail
    Scenario: The user can edit the default Status account from Settings
        Given the user opens app settings screen
        And the user opens the wallet settings
        When the user selects the default Status account
        And the user edits default Status account to "Default" name and "#f6af3c" color
        Then the default account is updated to be named "DefaultStatus account" with color "#f6af3c"

    Scenario Outline: The user can generate new account from Settings for default Status account keypair
        Given the user opens app settings screen
        And the user opens the wallet settings
        When the user adds a generated account with "<name>" color "#<color>" and emoji "<emoji>" in Settings
        Then the account is present with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>" in the accounts list in Settings

        Examples:
            | name    | color  | emoji      | emoji_unicode |
            | GenAcc1 | 2a4af5 | sunglasses | 1f60e |