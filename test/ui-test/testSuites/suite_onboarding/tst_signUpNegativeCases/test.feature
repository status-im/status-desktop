Feature: Status Desktop Sign Up, negative cases

  As a user I do not want to Sign-up with incorrect data into the Status Desktop application.

  The following scenarios cover negative Sign up process scenarios when trying to do it with wrong data.

   The feature start sequence is the following (setup on its own `bdd_hooks`):
   ** given A first time user lands on the status desktop and generates new key

   [Cleanup]
   ** the user navigates to first onboarding page

  #Consider passing examples in a datatable to cut overhead
  Scenario Outline: Entering a <reason> username
    Given the user clears the display name field
    When the user enters "<username>" into the display name field
    Then the Next button is disabled

    Examples:
      | username | reason       |
      |          | empty        |
      | 1234     | 1 char short |
      | 1234!    | invalid char |


  Scenario Outline: <reason> password creation
  Given the user inputs username "tester123"
   When "<password-1>" is entered into the first password field
   And "<password-2>" is entered into the second password field
   Then the create password button is "<button-state>"

   Examples:
   | password-1       | password-2             | button-state | reason                     |
   |                  |                        | disabled     | empty                      |
   | 1234567890       |                        | disabled     | valid/empty                |
   |                  | 1234567890             | disabled     | empty/valid                |
   | 123456789        | 123456789              | disabled     | 1 char short               |
   | TesTEr16843/!@01 | 1234567890             | disabled     | mismatched                 |
  # | TesTEr16843/!@01 | TesTEr16843/!@01       | enabled      | matching valid passwords   |


  Scenario Outline: Invalid confirmation-again password
    Given the user inputs username "tester123"
    When "<password>" is entered into the first password field
    And "<password>" is entered into the second password field
    And the create password button is clicked
    When "<wrongpassword>" is entered into the third password field
    Then the finalise password button is disabled

    Examples:
      | username  | wrongpassword   | password         |
      | tester123 | TesTEr16843/!@) | TesTEr16843/!@01 |
