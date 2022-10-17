#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file	test.feature
# *
# * \test	Status Sign up
# * \date	August 2022
# **
# *****************************************************************************/
Feature: Password strength validation including UI pixel-perfect validation

    @merge @mayfail
    Scenario Outline: As a user I want to see the strength of the password

		Given A first time user lands on the status desktop and generates new key
		When the user inputs username <username>
		When user inputs the following <password> with ui-component onboarding_newPsw_Input
		Then the password strength indicator is <strength>

		Examples:
	      | username  | password   | strength                          |
	      | tester123 | abc        | lower_very_weak                   |
	      | tester124 | ABC        | upper_very_weak                   |
	      | tester124 | 123        | numbers_very_weak                 |
	      | tester124 | +_!        | symbols_very_weak                 |
	      | tester124 | +1_3!48    | numbers_symbols_weak              |
	      | tester124 | +1_3!48a   | numbers_symbols_lower_so-so       |
	      | tester124 | +1_3!48aT  | numbers_symbols_lower_upper_good  |
	      | tester124 | +1_3!48aTq | numbers_symbols_lower_upper_great |
