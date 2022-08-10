Feature: Status Desktop Settings Menu

    As a user I want to login the app go to Settings and go through all settings menu
    checking the result of each menu item

    Background: Sign up and open settings section
        Given A first time user lands on the status desktop and generates new key
        When user signs up with username tester123 and password TesTEr16843/!@00
        Then the user lands on the signed in app
        When the user opens app settings screen

    Scenario: The user quits the app
        When the user clicks on Sign out and Quit
        Then the app is closed