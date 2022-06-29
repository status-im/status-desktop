#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file	test.feature
# *
# * \test	Status Sign up
# * \date	May 2022
# **
# *****************************************************************************/

Feature: Status Desktop Sign Up

  As a user I want to Sign-up into the Status Desktop application.
  The following scenarios cover Sign up process.

  Scenario: User signs up and signs in with password
    Given A first time user lands on the status desktop and generates new key
    When user signs up with username tester123 and password TesTEr16843/!@00
    Then the user lands on the signed in app


  Scenario Outline: User cannot sign up with wrong username format
    Given A first time user lands on the status desktop and generates new key
    When user inputs the following <username> with ui-component mainWindow_edit_TextEdit
    Then the following ui-component mainWindow_Next_StatusBaseText is not enabled

    Examples:
      | username |
      | Athl     |
      | Nervo    |
      | Gra      |
      | tester3@ |


  Scenario Outline: User cannot sign up with wrong password format
    Given A first time user lands on the status desktop and generates new key
    When the user inputs username <username>

	# Input wrong password format in both new password and confirmation input and verify create password button is not enabled
    When user inputs the following <wrongpassword> with ui-component loginView_passwordInput
    And user inputs the following <wrongpassword> with ui-component mainWindow_inputValue_StyledTextField
    Then the following ui-component mainWindow_Create_password_StatusBaseText is not enabled


    # Input right password format in new password input but incorrect in confirmation password input and verify create password button is not enabled
    When user inputs the following <password> with ui-component loginView_passwordInput
    And user inputs the following <wrongpassword> with ui-component mainWindow_inputValue_StyledTextField
    Then the following ui-component mainWindow_Create_password_StatusBaseText is not enabled

    Examples:
      | username  | wrongpassword | password         |
      | tester123 | Invalid34     | TesTEr16843/!@00 |
      | tester124 | badP          | TesTEr16843/!@01 |
      | tester124 | bad2!s        | TesTEr16843/!@01 |


  Scenario Outline: User cannot finish Sign Up and Sign In process with wrong password
    Given A first time user lands on the status desktop and generates new key
    When the user inputs username <username>

	# Input correct password format in both new password and confirmation input
    When user inputs the following <password> with ui-component loginView_passwordInput
    And user inputs the following  <password> with ui-component mainWindow_inputValue_StyledTextField
    And user clicks on the following ui-component mainWindow_Create_password_StatusBaseText

	# Input wrong password in final password input and verify password creation button is not enabled
    When user inputs the following <wrongpassword> with ui-component loginView_passwordInput
    Then the following ui-component mainWindow_Finalise_Status_Password_Creation_StatusBaseText is not enabled

    Examples:
      | username  | wrongpassword        | password         |
      | tester123 | Invalid34            | TesTEr16843/!@00 |
      | tester123 | TesTEr16843/!@)      | TesTEr16843/!@01 |


	Scenario: User signs up with imported seed phrase

		Given A first time user lands on the status desktop and navigates to import seed phrase
		When The user inputs 12 seed phrases
			| phrases   | occurrence |
			| lawn      | 1   	   |
			| corn      | 3   	   |
			| paddle    | 5          |
			| survey    | 7          |
			| shrimp    | 9          |
			| mind      | 11         |
			| select    | 2    	   |
			| gaze      | 4          |
			| arrest    | 6          |
			| pear      | 8          |
			| reduce    | 10         |
			| scan      | 12         |
		And user clicks on the following ui-component mainWindow_submitButton_StatusButton
		When user signs up with username tester123 and password TesTEr16843/!@00
		Then the user lands on the signed in app
		When the user opens app settings screen
		And  the user activates wallet