Feature: Status Desktop Settings Menu

    As a user I want to login the app go to Settings and go through all settings menu
    checking the result of each menu item

    Background: Sign up and open settings section
        Given A first time user lands on the status desktop and generates new key
        When user signs up with username "tester123" and password "TesTEr16843/!@00"
        Then the user lands on the signed in app
        When the user opens app settings screen

	@merge @mayfail
    Scenario: The user quits the app
        When the user clicks on Sign out and Quit
        Then the app is closed

	@merge @mayfail
    Scenario: User can backup seed phrase
        When the user activates wallet and opens the wallet settings
        And the user backs up the wallet seed phrase
        Then the backup seed phrase indicator is not displayed

	@merge
    Scenario: The user can switch state to offline
    	When the users switches state to offline
    	Then the user appears offline
    	When the user restarts the app
    	And the user "tester123" logs in with password "TesTEr16843/!@00"
    	Then the user appears offline

	@merge
    Scenario: The user can switch state to online
        When the users switches state to offline
    	And the user restarts the app
    	And the user "tester123" logs in with password "TesTEr16843/!@00"
    	Then the user appears offline
        When the users switches state to online
    	Then the user appears online
    	When the user restarts the app
    	And the user "tester123" logs in with password "TesTEr16843/!@00"
    	Then the user appears online

Scenario: The user can switch state to automatic
        When the users switches state to automatic
    	Then the user status is automatic
    	When the user restarts the app
    	And the user "tester123" logs in with password "TesTEr16843/!@00"
    	Then the user status is automatic

Scenario: The user can change the password and login with new password
    	When the user changes the password from TesTEr16843/!@00 to NewPassword@12345
    	And the user restarts the app
    	And the user "tester123" logs in with password "NewPassword@12345"
    	Then the user lands on the signed in app
