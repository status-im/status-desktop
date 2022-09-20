Feature: Status Desktop Transaction

    As a user I want to perform transaction

    Background: Sign up & Enable wallet section & Toggle test networks
		Given A first time user lands on the status desktop and navigates to import seed phrase
		When The user inputs the seed phrase pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial
		And user clicks on the following ui-component seedPhraseView_Submit_Button
		When user signs up with username tester123 and password qqqqqqqqqq
		Then the user lands on the signed in app
		When the user opens app settings screen
		And the user activates wallet and opens the wallet settings
		And the user toggles test networks
		And the user opens wallet screen
		And the user accepts the signing phrase

	@mayfail
    Scenario Outline: User sends a transaction
 		When the user sends a transaction to himself from account Status account of <amount> <token> on <chain_name> with password qqqqqqqqqq
		Then the transaction is in progress

    	Examples:
      	  | amount   | token | chain_name |
      	  | 1 		 | ETH   | Goerli     |
      	  | 0 		 | ETH   | Goerli     |
      	  | 1 		 | STT   | Goerli     |
      	  | 0 		 | STT   | Goerli     |

    @mayfail
    Scenario: User registers a ENS name
		When the user registers a random ens name with password qqqqqqqqqq
		Then the transaction is in progress
