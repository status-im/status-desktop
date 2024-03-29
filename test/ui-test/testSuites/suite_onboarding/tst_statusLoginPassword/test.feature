#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file	test.feature
# *
# * \test	Status Desktop - Login
# * \date	February 2022
# **
# *****************************************************************************/

Feature: Status Desktop login

    As a user I want to login into the Status Desktop application.

    The following scenarios cover login by using a password.

    The feature start sequence follows the global one (setup on global `bdd_hooks`): No additional steps

    Scenario Outline: User tries to login with a valid password
        Given A first time user lands on the status desktop and generates new key
        And the user signs up with username "<username>" and password "<password>"
        And the user lands on the signed in app
        When the user restarts the app
        And the user "<username>" logs in with password "<password>"
        Then the user lands on the signed in app

        Examples:
            | username 		   | password          |
            | Athletic_Prime   | TesTEr16843/!@00  |

    Scenario Outline: User tries to login with an invalid password
        Given A first time user lands on the status desktop and generates new key
        And the user signs up with username "<username>" and password "<password>"
        And the user lands on the signed in app
        When the user restarts the app
        And the user "<username>" logs in with password "<wrongpassword>"
        Then the user is NOT able to login to Status Desktop application

        Examples:
             | username 		  | password           |  wrongpassword    |
             | Nervous_Pesky      | TesTEr16843/!@22   |  WrongPSW         |
