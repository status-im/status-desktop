Feature: Status Desktop Transaction

    As a user I want to perform transactions

    The feature start sequence is the following (setup on its own `bdd_hooks`):

	** given A first time user lands on the status desktop and navigates to import seed phrase
	** and the user inputs the seed phrase "pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial"
	** and the user clicks on the following ui-component seedPhraseView_Submit_Button
	** and the user signs up with username "tester123" and password "qqqqqqqqqq"
	** and the user lands on the signed in app
	** and the user opens app settings screen
	** and the user opens the wallet settings
	** and the user toggles test networks
	** and the user opens wallet screen
	** and the user accepts the signing phrase

	@mayfail
    Scenario Outline: The user sends a transaction
 		When the user sends a transaction to himself from account "Status account" of "<amount>" "<token>" on "<chain_name>" with password "qqqqqqqqqq"
		Then the transaction is in progress

    	Examples:
      	  | amount   | token | chain_name |
          | 1		 | ETH   | Ethereum Mainnet     |
#      	  | 1 		 | ETH   | Goerli               |
#      	  | 1 		 | STT   | Goerli               |
#      	  | 100      | STT   | Goerli               |

    @mayfail
    Scenario: The user registers an ENS name
		When the user registers a random ens name with password "qqqqqqqqqq"
		Then the transaction is in progress
