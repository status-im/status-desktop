Feature: Status Desktop Sign Up, negative cases

  As a user I do not want to Sign-up with incorrect data into the Status Desktop application.

  The following scenarios cover negative Sign up process scenarios when trying to do it with wrong data.

   The feature start sequence is the following (setup on its own `bdd_hooks`):
   ** given A first time user lands on the status desktop and generates new key

   [Cleanup]
   ** the user navigates to first onboarding page

  Scenario Outline: The user cannot sign up with wrong username format
    Given the user clears input "onboarding_DiplayName_Input"
    When the user inputs the following "<username>" with ui-component "onboarding_DiplayName_Input"
    Then the following ui-component "onboarding_DetailsView_NextButton" is not enabled

    Examples:
      | username |
      | Athl     |
      | Gra      |
      | tester3@ |

  Scenario Outline: The user cannot sign up with wrong password format in both new password and confirmation input
   Given the user inputs username "<username>"
    When the user inputs the following "<wrongpassword>" with ui-component "onboarding_newPsw_Input"
    And the user inputs the following "<wrongpassword>" with ui-component "onboarding_confirmPsw_Input"
    Then the following ui-component "onboarding_create_password_button" is not enabled

    Examples:
      | username  | wrongpassword |
      | tester124 | badP          |

  Scenario Outline: The user cannot sign up with right password format in new password input but incorrect in confirmation password input
    Given the user inputs username "<username>"
    And the user inputs the following "<password>" with ui-component "onboarding_newPsw_Input"
    When the user inputs the following "<wrongpassword>" with ui-component "onboarding_confirmPsw_Input"
    Then the following ui-component "onboarding_create_password_button" is not enabled

    Examples:
      | username  | wrongpassword | password         |
      | tester124 | bad2!s        | TesTEr16843/!@01 |

  Scenario Outline: The user cannot sign up with incorrect confirmation-again password
    Given the user inputs username "<username>"
    And the user inputs the following "<password>" with ui-component "onboarding_newPsw_Input"
    And the user inputs the following "<password>" with ui-component "onboarding_confirmPsw_Input"
    And the user clicks on the following ui-component "onboarding_create_password_button"
    When the user inputs the following "<wrongpassword>" with ui-component "onboarding_confirmPswAgain_Input"
    Then the following ui-component "onboarding_finalise_password_button" is not enabled

    Examples:
      | username  | wrongpassword   | password         |
      | tester123 | TesTEr16843/!@) | TesTEr16843/!@01 |

  Scenario Outline: The user cannot finish Sign Up and Sign In process with wrong password format in both new password and confirmation input
    Given the user inputs username "<username>"
    When the user inputs the following "<wrongpassword>" with ui-component "onboarding_newPsw_Input"
    And the user inputs the following "<wrongpassword>" with ui-component "onboarding_confirmPsw_Input"
    Then the following ui-component "onboarding_create_password_button" is not enabled

    Examples:
      | username  | wrongpassword   |
      | tester123 | Invalid34       |

  Scenario Outline: The user cannot finish Sign Up and Sign In process with right password format in new password input but incorrect in confirmation password input
    Given the user inputs username "<username>"
    And the user inputs the following "<password>" with ui-component "onboarding_newPsw_Input"
    When the user inputs the following "<wrongpassword>" with ui-component "onboarding_confirmPsw_Input"
    Then the following ui-component "onboarding_create_password_button" is not enabled

    Examples:
      | username  | wrongpassword   | password         |
      | tester123 | Invalid34       | TesTEr16843/!@00 |

  Scenario Outline: The user cannot finish Sign Up and Sign In process with incorrect confirmation-again password
    Given the user inputs username "<username>"
    And the user inputs the following "<password>" with ui-component "onboarding_newPsw_Input"
    And the user inputs the following "<password>" with ui-component "onboarding_confirmPsw_Input"
    And the user clicks on the following ui-component "onboarding_create_password_button"
    When the user inputs the following "<wrongpassword>" with ui-component "onboarding_confirmPswAgain_Input"
    Then the following ui-component "onboarding_finalise_password_button" is not enabled

    Examples:
      | username  | wrongpassword   | password         |
      | tester123 | Invalid34       | TesTEr16843/!@00 |
