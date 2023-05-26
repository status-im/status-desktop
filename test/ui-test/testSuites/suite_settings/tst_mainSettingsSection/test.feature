Feature: Status Desktop Main Settings Section

    As a user I want to login the app go to Settings and make basic settings actions like change my online state and/or store my seed phrase.


    Background: Open settings section
        Given A first time user lands on the status desktop and generates new key
        And the user signs up with username "tester123" and password "TesTEr16843/!@00"
        And the user lands on the signed in app
        And the user opens app settings screen

    Scenario: The user can backup seed phrase
        When the user backs up the wallet seed phrase
        Then the backup seed phrase indicator is not displayed
        And the Secure Your Seed Phrase Banner is not displayed

	@mayfail
    Scenario: The user can switch state to offline
    	When the users switches state to offline
    	Then the user appears offline

    	Given the user restarts the app
    	And the user "tester123" logs in with password "TesTEr16843/!@00"
    	Then the user lands on the signed in app
    	Then the user appears offline

	@mayfail
    Scenario: The user can switch state to online
        When the users switches state to offline
    	And the user restarts the app
    	And the user "tester123" logs in with password "TesTEr16843/!@00"
    	Then the user lands on the signed in app
    	Then the user appears offline

        When the users switches state to online
    	Then the user appears online

    	When the user restarts the app
    	And the user "tester123" logs in with password "TesTEr16843/!@00"
    	Then the user lands on the signed in app
    	Then the user appears online

	@mayfail
	Scenario: The user can switch state to automatic
        When the users switches state to automatic
    	Then the user status is automatic

    	When the user restarts the app
    	And the user "tester123" logs in with password "TesTEr16843/!@00"
    	Then the user lands on the signed in app
    	Then the user status is automatic

	# https://github.com/status-im/status-desktop/issues/10287
	@mayfail
	Scenario: The user can change the password and login with new password
    	When the user changes the password from TesTEr16843/!@00 to NewPassword@12345
    	And the user restarts the app
    	And the user "tester123" logs in with password "NewPassword@12345"
    	Then the user lands on the signed in app
