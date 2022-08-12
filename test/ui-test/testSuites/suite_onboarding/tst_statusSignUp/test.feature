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
    When user inputs the following <username> with ui-component onboarding_DiplayName_Input
    Then the following ui-component onboarding_DetailsView_NextButton is not enabled

    Examples:
      | username |
      | Athl     |
      | Gra      |
      | tester3@ |


  Scenario Outline: User cannot sign up with wrong password format in both new password and confirmation input
    Given A first time user lands on the status desktop and generates new key
    When the user inputs username <username>
    When user inputs the following <wrongpassword> with ui-component onboarding_newPsw_Input
    And user inputs the following <wrongpassword> with ui-component onboarding_confirmPsw_Input
    Then the following ui-component onboarding_create_password_button is not enabled

    Examples:
      | username  | wrongpassword |
      | tester123 | Invalid34     |
      | tester124 | badP          |
      | tester124 | bad2!s        |


  Scenario Outline: User cannot sign up with right password format in new password input but incorrect in confirmation password input
    Given A first time user lands on the status desktop and generates new key
    When the user inputs username <username>
    When user inputs the following <password> with ui-component onboarding_newPsw_Input
    And user inputs the following <wrongpassword> with ui-component onboarding_confirmPsw_Input
    Then the following ui-component onboarding_create_password_button is not enabled

    Examples:
      | username  | wrongpassword | password         |
      | tester123 | Invalid34     | TesTEr16843/!@00 |
      | tester124 | badP          | TesTEr16843/!@01 |
      | tester124 | bad2!s        | TesTEr16843/!@01 |

  Scenario Outline: User cannot sign up with incorrect confirmation-again password
    Given A first time user lands on the status desktop and generates new key
    When the user inputs username <username>
    When user inputs the following <password> with ui-component onboarding_newPsw_Input
    And user inputs the following  <password> with ui-component onboarding_confirmPsw_Input
    And user clicks on the following ui-component onboarding_create_password_button
    And user inputs the following  <wrongpassword> with ui-component onboarding_confirmPswAgain_Input
    Then the following ui-component onboarding_finalise_password_button is not enabled

    Examples:
      | username  | wrongpassword   | password         |
      | tester123 | Invalid34       | TesTEr16843/!@00 |
      | tester123 | TesTEr16843/!@) | TesTEr16843/!@01 |

  Scenario Outline: User cannot finish Sign Up and Sign In process with wrong password format in both new password and confirmation input
    Given A first time user lands on the status desktop and generates new key
    When the user inputs username <username>
    When user inputs the following <wrongpassword> with ui-component onboarding_newPsw_Input
    And user inputs the following  <wrongpassword> with ui-component onboarding_confirmPsw_Input
    Then the following ui-component onboarding_create_password_button is not enabled

    Examples:
      | username  | wrongpassword   |
      | tester123 | Invalid34       |

  Scenario Outline: User cannot finish Sign Up and Sign In process with right password format in new password input but incorrect in confirmation password input
    Given A first time user lands on the status desktop and generates new key
    When the user inputs username <username>
    When user inputs the following <password> with ui-component onboarding_newPsw_Input
    And user inputs the following  <wrongpassword> with ui-component onboarding_confirmPsw_Input
    Then the following ui-component onboarding_create_password_button is not enabled

    Examples:
      | username  | wrongpassword   | password         |
      | tester123 | Invalid34       | TesTEr16843/!@00 |
      | tester123 | TesTEr16843/!@) | TesTEr16843/!@01 |

  Scenario Outline: User cannot finish Sign Up and Sign In process with incorrect confirmation-again password
    Given A first time user lands on the status desktop and generates new key
    When the user inputs username <username>
    When user inputs the following <password> with ui-component onboarding_newPsw_Input
    And user inputs the following  <password> with ui-component onboarding_confirmPsw_Input
    And user clicks on the following ui-component onboarding_create_password_button
    And user inputs the following  <wrongpassword> with ui-component onboarding_confirmPswAgain_Input
    Then the following ui-component onboarding_finalise_password_button is not enabled

    Examples:
      | username  | wrongpassword   | password         |
      | tester123 | Invalid34       | TesTEr16843/!@00 |
      | tester123 | TesTEr16843/!@) | TesTEr16843/!@01 |

  Scenario Outline: User signs up with imported seed phrase

    Given A first time user lands on the status desktop and navigates to import seed phrase
    When The user inputs the seed phrase <seed>
    And user clicks on the following ui-component seedPhraseView_Submit_Button
    When user signs up with username tester123 and password TesTEr16843/!@00
    Then the user lands on the signed in app
    Examples:
    	| seed | address |
    	| truth gold urban vital rose market legal release border gospel leave fame | 0x8672E2f1a7b28cda8bcaBb53B52c686ccB7735c3 |
		| lemon card easy goose keen divide cabbage daughter glide glad sense dice promote present august obey stay cheese | 0xdd06a08d469dd61Cb2E5ECE30f5D16019eBe0fc9 |
		| provide between target maze travel enroll edge churn random sight grass lion diet sugar cable fiction reflect reason gaze camp tone maximum task unlock | 0xCb59031d11D233112CB57DFd667fE1FF6Cd7b6Da |

  Scenario: User signs up with wrong imported seed phrase

    Given A first time user lands on the status desktop and navigates to import seed phrase
    When The user inputs the seed phrase truth gold urban vital rose market legal release border gospel leave potato
    And user clicks on the following ui-component seedPhraseView_Submit_Button
    Then the following ui-component seedPhraseView_Submit_Button is not enabled
    And the invalid seed text is visible

  Scenario: After Signing up the Profile state should be online
    Given A first time user lands on the status desktop and generates new key
    When user signs up with username tester123 and password TesTEr16843/!@00
    Then the user is online