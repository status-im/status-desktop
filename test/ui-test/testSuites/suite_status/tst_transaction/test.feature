Feature: Status Desktop Transaction

   As a user I want to perform transaction

   Background: Sign up & Enable wallet section & Toggle test networks
		Given A first time user lands on the status desktop and generates new key
		When user signs up with username tester123 and password TesTEr16843/!@00
		Then the user lands on the signed in app
		When the user opens app settings screen
		When the user activates wallet and opens the wallet settings
		When the user toggles test networks
		When the user opens wallet screen
		When the user accepts the signing phrase
		When the user imports a seed phrase with one and TesTEr16843/!@00 and pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial

    @mayfail
    Scenario Outline: User sends a transaction
        When the user sends a transaction to himself from account one of <amount> <token> on <chain_name> with password TesTEr16843/!@00
        Then the transaction is in progress

    Examples:
     	  | amount   | token | chain_name |
     	  | 0.000001 | ETH   | Ropsten    |
     	  | 0 		 | ETH   | Ropsten    |