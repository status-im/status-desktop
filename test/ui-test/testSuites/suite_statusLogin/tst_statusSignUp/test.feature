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

    Scenario: User signs up with password

        Given A first time user lands on the status desktop and generates new key
        When user inputs username tester123 and password TesTEr16843/!@00
        Then the user lands on the signed in app

