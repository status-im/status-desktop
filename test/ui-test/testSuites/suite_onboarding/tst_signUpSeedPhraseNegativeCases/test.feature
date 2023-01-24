Feature: Status Desktop Sign Up with seed phrase, negative cases

  As a user I do not want to Sign-up with incorrect seed phrase into the Status Desktop application.

  The following scenarios cover negative Sign up process scenarios when trying to do it by seed phrase.

  The feature start sequence follows the global one (setup on global `bdd_hooks`): No additional steps

  @mayfail
  Scenario: User signs up with wrong imported seed phrase

    Given A first time user lands on the status desktop and navigates to import seed phrase
    When the user inputs the seed phrase "truth gold urban vital rose market legal release border gospel leave potato"
    And the user clicks on the following ui-component "seedPhraseView_Submit_Button"
    Then the following ui-component "seedPhraseView_Submit_Button" is not enabled
    And the invalid seed text is visible
