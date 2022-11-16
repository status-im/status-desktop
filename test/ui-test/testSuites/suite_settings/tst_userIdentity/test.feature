Feature: User Identity

    As a user I want to set my identity, that is: display name, bio and social links.


    The feature start sequence is the following (setup on its own `bdd_hooks`):
    ** given A first time user lands on the status desktop and generates new key
    ** when user signs up with username "tester123" and password "TesTEr16843/!@00"
    ** and the user lands on the signed in app

	# TODO: Scenario broken due to new user profile design. It will be addressed in task #8281
	@mayfail
    Scenario: User sets display name, bio and social links
        When the user opens app settings screen
        And the user opens the profile settings
        Then the user's display name should be "tester123"
        And the user's bio should be empty
        And the user's social links should be empty
        When the user sets display name to "tester123_changed"
        And the user sets bio to "Hello, I am super tester!"
        And the user sets display links to twitter: "twitter_handle", personal site: "status.im", "customLink": "customUrl"
        And the user restarts the app
        And the user "tester123_changed" logs in with password "TesTEr16843/!@00"
        Then the user lands on the signed in app
        When the user opens app settings screen
        And the user opens the profile settings
        Then the user's display name should be "tester123_changed"
        And the user's bio should be "Hello, I am super tester!"
        And the user's social links should be: "twitter_handle", personal site: "status.im", "customLink": "customUrl"

	# TODO: Scenario broken due to new user profile design. It will be addressed in task #8281
	@mayfail
    Scenario: The user can change own display name in profile popup
        When the user opens own profile popup
        Then in profile popup the user's display name should be "tester123"
        When in profile popup the user sets display name to "tester123_changed"
        Then in profile popup the user's display name should be "tester123_changed"