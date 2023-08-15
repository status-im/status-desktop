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

  The following scenarios cover positive Sign up process scenarios.

  The feature start sequence follows the global one (setup on global `bdd_hooks`): No additional steps

  Scenario: The user signs up with password and its state is online
    Given A first time user lands on the status desktop and generates new key
    When the user signs up with username "tester123" and password "TesTEr16843/!@00"
    Then the user lands on the signed in app
    And the user is online

  Scenario Outline: The user signs up with imported seed phrase and and its state is online
    Given A first time user lands on the status desktop and navigates to import seed phrase
    When the user inputs the seed phrase "<seed>"
    And the user clicks on the following ui-component "seedPhraseView_Submit_Button"
    Given the user signs up with username "tester123" and password "TesTEr16843/!@00"
    Then the user lands on the signed in app
    And the user is online

    Examples:
    	| seed | address |
    	| truth gold urban vital rose market legal release border gospel leave fame | 0x8672E2f1a7b28cda8bcaBb53B52c686ccB7735c3 |
		| lemon card easy goose keen divide cabbage daughter glide glad sense dice promote present august obey stay cheese | 0xdd06a08d469dd61Cb2E5ECE30f5D16019eBe0fc9 |
		| provide between target maze travel enroll edge churn random sight grass lion diet sugar cable fiction reflect reason gaze camp tone maximum task unlock | 0xCb59031d11D233112CB57DFd667fE1FF6Cd7b6Da |

  Scenario: The user signs up with a profile image
    Given A first time user lands on the status desktop and generates new key
    And the user signs up with profileImage "doggo.jpeg", username "tester123" and password "TesTEr16843/!@00"
    And my profile modal has the updated profile image
    And the profile setting has the updated profile image
    And the user restarts the app
    And a screenshot of the profileImage is taken
    When the user logs in with password "TesTEr16843/!@00"
    Then the user lands on the signed in app
    And the profile navigation bar has the updated profile image
