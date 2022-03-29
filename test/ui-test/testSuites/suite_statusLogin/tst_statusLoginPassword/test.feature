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

		Given A Status Desktop <account> and <password> with <languageType> as a preference language
         When the user tries to login with valid credentials
         Then the user is able to login to Status Desktop application
 	Examples:
            | account 					   | password   | languageType |
            | Athletic Prime Springtail    | Test_1234  | english      |
            | Nervous Pesky Serpent  	   | Test_1234  | english      |
            | Granular Diligent Gorilla    | Test_1234  | english      |


    Scenario Outline: User tries to login with an invalid password

        Given A Status Desktop <account> and <password> with <languageType> as a preference language
         When the user tries to login with invalid credentials
         Then the user is NOT able to login to Status Desktop application
	Examples:
             | account 					   | password    | languageType  |
             | Athletic Prime Springtail   | Invalid34   | english       |
             | Granular Diligent Gorilla   | Testpwd 	 | english  	 |
             | Nervous Pesky Serpent  	   | WrongPSW    | english       |
