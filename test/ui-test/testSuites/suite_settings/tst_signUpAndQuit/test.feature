Feature: Status Desktop Sign out and Quit

    As a user I want to login the app go to Settings and make basic settings actions related to extra settings settions (

    The feature start sequence follows the global one (setup on global `bdd_hooks`): No additional steps

    Background: Sign up and open settings section
        Given A first time user lands on the status desktop and generates new key
        And the user signs up with username "tester123" and password "TesTEr16843/!@00"
        And the user lands on the signed in app
        Given the user opens app settings screen

    Scenario: The user quits the app
        When the user clicks on Sign out and Quit
        Then the app is closed