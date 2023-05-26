Feature: User Identity

    As a user I want to set my identity, that is: display name, bio and social links.

    The feature start sequence follows the global one (setup on global `bdd_hooks`): No additional steps

    Background: Sign up and open settings section
        Given A first time user lands on the status desktop and generates new key
        And the user signs up with username "tester123" and password "TesTEr16843/!@00"
        And the user lands on the signed in app

    Scenario Outline: The user sets display name, bio and social links
        Given the user opens app settings screen
        And the user opens the profile settings
        And the user's display name is "tester123"
        And the user's bio is empty
        And the user's social links are empty

        When the user sets display name to "<user>"
        And the user sets bio to "<bio>"
        And the user sets social links to:
        | testerTwitter  	 |
        | status.im 	 	 |
        | testerGithub   	 |
        | testerTube 	 	 |
        | testerDiscord  	 |
        | testerTelegram 	 |
        | customLink	 	 |
        | https://status.im/ |
        And the user restarts the app
        And the user "<user>" logs in with password "TesTEr16843/!@00"
        And the user lands on the signed in app
        And the user opens app settings screen
        And the user opens the profile settings

        Then the user's display name is "<user>"
        And the user's bio is "<bio>"
        And the user's social links are:
        | testerTwitter  	 |
        | status.im 	 	 |
        | testerGithub   	 |
        | testerTube 	 	 |
        | testerDiscord  	 |
        | testerTelegram 	 |
        | customLink	 	 |
        | https://status.im/ |

        Examples:
		| user 				| bio 						|
		| tester123_changed | Hello, I am super tester! |


 	@mayfail
    Scenario Outline: The user can change own display name in profile popup
        Given the user opens own profile popup
        And the user's display name is "tester123"
        When the user navigates to edit profile
        And the user sets display name to "<user>"
        And the user opens own profile popup
        Then the user's display name is "<user>"

        Examples:
		| user 				|
		| tester123_changed |
