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

    Scenario Outline: User tries to login with a valid password

		Given A first time user lands on the status desktop and generates new key
        When user inputs username <account> and password <password>
        Given the application is restarted
		Given A Status Desktop <account> and <password>
        When the user tries to login with valid credentials
        Then the user is able to login to Status Desktop application
 	Examples:
            | account 		   | password          |
            | Athletic_Prime   | TesTEr16843/!@00  |
            | Nervous_Pesky    | TesTEr16843/!@11  |
            | Granular_Diligent| TesTEr16843/!@22  |


    #Scenario Outline: User tries to login with an invalid password

        #Given A Status Desktop <account> and <password>
        # When the user tries to login with invalid credentials
        # Then the user is NOT able to login to Status Desktop application
	#Examples:
            # | account 			  | password    |
             #| Athletic_Prime     | Invalid34   |
             #| Granular_Diligent  | Testpwd     |
             #| Nervous_Pesky      | WrongPSW    |
