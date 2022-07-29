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
      | tester123 | TesTEr16843/!@) |

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

  Scenario: User signs up with imported 12 seed phrase

    Given A first time user lands on the status desktop and navigates to import seed phrase
    When The user inputs 12 seed phrases
      | phrases | occurrence |
      | lawn    | 1          |
      | corn    | 3          |
      | paddle  | 5          |
      | survey  | 7          |
      | shrimp  | 9          |
      | mind    | 11         |
      | select  | 2          |
      | gaze    | 4          |
      | arrest  | 6          |
      | pear    | 8          |
      | reduce  | 10         |
      | scan    | 12         |
    And user clicks on the following ui-component seedPhraseView_Submit_Button
    When user signs up with username tester123 and password TesTEr16843/!@00
    Then the user lands on the signed in app
    When the user opens app settings screen
    And  the user activates wallet and opens the wallet settings
    Then the 12 seed phrase address is 0x8285cb9bf17b23d64a489a8dad29163dd227d0fd displayed in the wallet


  Scenario: User signs up with imported 18 seed phrase

    Given A first time user lands on the status desktop and navigates to import seed phrase
    When The user inputs 18 seed phrases
      | phrases  | occurrence |
      | flip     | 1          |
      | foam     | 4          |
      | time     | 7          |
      | sight    | 10         |
      | scheme   | 13         |
      | describe | 16         |
      | candy    | 2          |
      | erosion  | 5          |
      | layer    | 8          |
      | depth    | 11         |
      | extend   | 14         |
      | dish     | 17         |
      | fog      | 3          |
      | seven    | 6          |
      | budget   | 9          |
      | denial   | 12         |
      | body     | 15         |
      | device   | 18         |

    And user clicks on the following ui-component seedPhraseView_Submit_Button
    When user signs up with username tester124 and password TesTEr16843/!@00
    Then the user lands on the signed in app
    When the user opens app settings screen
    And  the user activates wallet and opens the wallet settings
    Then the 18 seed phrase address is 0xba1d0d6ef35df8751df5faf55ebd885ad0e877b0 displayed in the wallet


  Scenario: User signs up with imported 24 seed phrase

    Given A first time user lands on the status desktop and navigates to import seed phrase
    When The user inputs 24 seed phrases
      | phrases  | occurrence |
      | abstract | 1          |
      | maple    | 5          |
      | license  | 9          |
      | damage   | 13         |
      | margin   | 17         |
      | marine   | 21         |
      | prevent  | 2          |
      | neutral  | 6          |
      | slender  | 10         |
      | unique   | 14         |
      | sphere   | 18         |
      | drama    | 22         |
      | exact    | 3          |
      | pottery  | 7          |
      | just     | 11         |
      | consider | 15         |
      | debate   | 19         |
      | dial     | 23         |
      | oil      | 4          |
      | deny     | 8          |
      | timber   | 12         |
      | angle    | 16         |
      | exhibit  | 20         |
      | actress  | 24         |

    And user clicks on the following ui-component mainWindow_submitseedPhraseView_Submit_ButtonButton_StatusButton
    When user signs up with username tester124 and password TesTEr16843/!@00
    Then the user lands on the signed in app
    When the user opens app settings screen
    And  the user activates wallet and opens the wallet settings
    Then the 24 seed phrase address is 0x28cf6770664821a51984daf5b9fb1b52e6538e4b displayed in the wallet

  Scenario: User signs up with wrong imported seed phrase

    Given A first time user lands on the status desktop and navigates to import seed phrase
    When The user inputs 24 seed phrases
      | phrases  | occurrence |
      | abstract | 1          |
      | maple    | 5          |
      | games    | 9          |
      | damage   | 13         |
      | margin   | 17         |
      | drama    | 21         |
      | prevent  | 2          |
      | neutral  | 6          |
      | timber   | 10         |
      | unique   | 14         |
      | sphere   | 18         |
      | only     | 22         |
      | exact    | 3          |
      | pottery  | 7          |
      | just     | 11         |
      | consider | 15         |
      | actress  | 19         |
      | dial     | 23         |
      | oil      | 4          |
      | deny     | 8          |
      | dial     | 12         |
      | timber   | 16         |
      | exhibit  | 20         |
      | house    | 24         |

    Then the following ui-component seedPhraseView_Submit_Button is not enabled
