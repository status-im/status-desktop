Feature: Settings -> Wallet


Background:
    Given A first time user lands on the status desktop and generates new key
	And the user signs up with username "tester123" and password "TesTEr16843/!@00"
	And the user lands on the signed in app
    And the user opens the wallet section
    And the user accepts the signing phrase

    Scenario: The user edits the default account
        Given the user opens app settings screen
        And the user opens the wallet settings
        When the user selects the default Status account
        And the user edits default Status account to "Default" name and "#f6af3c" color
        Then the default account is updated to be named "DefaultStatus account" with color "#f6af3c"