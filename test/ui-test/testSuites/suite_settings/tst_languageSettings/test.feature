#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file	test.feature
# *
# * \test	Status Language Settings
# * \date	August 2022
# **
# *****************************************************************************/
Feature: Status Language Settings

    As a user I want to change the application language.

    The following scenarios cover basic language changed validations

    Background:

    	Given A first time user lands on the status desktop and generates new key
    	And the user signs up with username "tester123" and password "TesTEr16843/!@00"
    	And the user lands on the signed in app
    	When the user opens app settings screen
    	And the user clicks on Language & Currency

	# Each language run takes 30 seconds, so only some of them are enabled until we can parallelize executions
	@mayfail
    Scenario Outline: The user is able to select a specific language and after a restart, the language is kept
		When the user opens the language selector
		And the user selects the language <native>
		Then the application displays <native> as the selected language
		When the user restarts the app
		And the user "tester123" logs in with password "TesTEr16843/!@00"
		Then the user lands on the signed in app
		When the user opens app settings screen
		And the user clicks on Language & Currency
		Then the application displays <native> as the selected language
	Examples:
	        | language                | native                  |
	        #| English                 | English                 |
	        | Arabic                  | العربية                 |
	        #| Bengali                 | বাংলা                    |
	        #| Chinese (China)         | 中文（中國）              |
	        #| Chinese (Taiwan)        | 中文（台灣）              |
	        #| Dutch                   | Nederlands              |
	        #| French                  | Français                |
	        #| German                  | Deutsch                 |
	        #| Hindi                   | हिन्दी                     |
	        #| Indonesian              | Bahasa Indonesia        |
	        #| Italian                 | Italiano                |
	        #| Japanese                | 日本語                   |
	        #| Korean                  | 한국어                    |
	        #| Malay                   | Bahasa Melayu           |
	        #| Polish                  | Polski                  |
	        #| Portuguese              | Português               |
	        #| Portuguese (Brazil) 	  | Português (Brasil)      |
	        #| Russian                 | Русский                 |
	        #| Spanish                 | Español                 |
	        #| Spanish (Latin America) | Español (Latinoamerica) |
	        #| Spanish (Argentina)     | Español (Argentina)     |
	        #| Tagalog                 | Tagalog                 |
	        #| Turkish                 | Türkçe                  |

	# Each language run takes 30 seconds, so only some of them are enabled until we can parallelize executions
	@mayfail
	Scenario Outline: The user is able to search and select a specific language and after a restart, the language is kept
		When the user opens the language selector
		And the user searches the language <native>
		And the user selects the language <native>
		Then the application displays <native> as the selected language
		When the user restarts the app
		And the user "tester123" logs in with password "TesTEr16843/!@00"
		Then the user lands on the signed in app
		When the user opens app settings screen
		And the user clicks on Language & Currency
		Then the application displays <native> as the selected language
	Examples:
	        | language                | native                  |
	        #| English                 | English                 |
	        #| Arabic                  | العربية                 |
	        #| Bengali                 | বাংলা                    |
	        #| Chinese (China)         | 中文（中國）              |
	        #| Chinese (Taiwan)        | 中文（台灣）              |
	        #| Dutch                   | Nederlands              |
	        #| French                  | Français                |
	        #| German                  | Deutsch                 |
	        #| Hindi                   | हिन्दी                     |
	        | Indonesian              | Bahasa Indonesia        |
	        #| Italian                 | Italiano                |
	        #| Japanese                | 日本語                   |
	        #| Korean                  | 한국어                    |
	        #| Malay                   | Bahasa Melayu           |
	        #| Polish                  | Polski                  |
	        #| Portuguese              | Português               |
	        #| Portuguese (Brazil) 	  | Português (Brasil)      |
	        #| Russian                 | Русский                 |
	        #| Spanish                 | Español                 |
	        #| Spanish (Latin America) | Español (Latinoamerica) |
	        #| Spanish (Argentina)     | Español (Argentina)     |
	        #| Tagalog                 | Tagalog                 |
	        #| Turkish                 | Türkçe                  |