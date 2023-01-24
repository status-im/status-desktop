Feature: Status Desktop Main Settings Section

    As a user I want to login the app go to Settings and make basic settings actions like change my online state and/or store my seed phrase.

    The feature start sequence is the following (setup on its own `bdd_hooks`):
    ** given A first time user lands on the status desktop and generates new key
    ** when user signs up with username "tester123" and password "TesTEr16843/!@00"
    ** and the user lands on the signed in app

    Background: Open settings section
        Given the user opens app settings screen

	# TODO: It must be reformulated or extracted to a different feature file bc preconditions of this feature file also include closing the backup seed phrase indicator at first instance
	# so the validation is not providing relevant information
	# TODO: It is also unstable. Needs to be checked.
    @mayfail
    Scenario: The user can backup seed phrase
        Given the user activates wallet
		And the user opens the wallet settings
        When the user backs up the wallet seed phrase
        Then the backup seed phrase indicator is not displayed

	@mayfail
    Scenario: The user can switch state to offline
    	When the users switches state to offline
    	Then the user appears offline

    	Given the user restarts the app
    	And the user "tester123" logs in with password "TesTEr16843/!@00"
    	Then the user appears offline

	@mayfail
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

	@mayfail
	Scenario: The user can switch state to automatic
        When the users switches state to automatic
    	Then the user status is automatic

    	When the user restarts the app
    	And the user "tester123" logs in with password "TesTEr16843/!@00"
    	Then the user status is automatic

	@mayfail
	Scenario: The user can change the password and login with new password
    	When the user changes the password from TesTEr16843/!@00 to NewPassword@12345
    	And the user restarts the app
    	And the user "tester123" logs in with password "NewPassword@12345"
    	Then the user lands on the signed in app
