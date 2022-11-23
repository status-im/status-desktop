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

    The feature start sequence is the following (setup on its own `bdd_hooks`):
    ** given A first time user lands on the status desktop and generates new key
    ** and the user inputs username "tester123"

    #Since there is only 1 scenario it would be better to have the background steps as part of the scenario, or at least within the feature.

    Scenario Outline: As a user I want to see the strength of the password
      Given the user clears password field
  		When the user enters "<password>" into the password field
  		Then the password strength indicator is "<strength>"

		Examples:
	      | password   | strength                          |
	      | abc        | lower_very_weak                   |
	      | ABC        | upper_very_weak                   |
	      | 123        | numbers_very_weak                 |
	      | +_!        | symbols_very_weak                 |
	      | +1_3!48    | numbers_symbols_weak              |
	      | +1_3!48a   | numbers_symbols_lower_so-so       |
	      | +1_3!48aT  | numbers_symbols_lower_upper_good  |
	      | +1_3!48aTq | numbers_symbols_lower_upper_great |
