# This is a sample .feature file
# Squish feature files use the Gherkin language for describing features, a short example
# is given below. You can find a more extensive introduction to the Gherkin format at
# https://cucumber.io/docs/gherkin/reference/
Feature: Status Desktop Chat

    As a user I want to join a room and chat.

    The following scenarios cover basic chat flows.

    Background:
         Given A first time user lands on the status desktop and generates new key
    	 When user signs up with username tester123 and password TesTEr16843/!@00
    	 Then the user lands on the signed in app

    Scenario: User joins a room and chats
		 When user joins chat room test
		 Then user is able to send chat message
		 | message  			 |
		 | Hello    			 |
		 | How are you    		 |
		 | I am from status   	 |
		 | tell me how you do?   |
