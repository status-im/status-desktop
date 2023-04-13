Feature: Status Desktop Wallet Section Wallet Account Management

    As a user I want to add edit remove different types of wallet accounts

    The feature start sequence is the following (setup on its own `bdd_hooks`):

    ** given A first time user lands on the status desktop and generates new key
    ** when user signs up with username "tester123" and password "TesTEr16843/!@00"
    ** and the user lands on the signed in app
    ** and the user opens the wallet section
    ** and the user accepts the signing phrase

	@mayfail
	Scenario Outline: The user edits default wallet account
        When the user clicks on the default wallet account
        And the user edits an account with "<name>" to "<new_name>" with color "#<new_color>" and emoji "<new_emoji>"
        Then the account is correctly displayed with "<new_name>" and "#<new_color>" and emoji unicode "<new_emoji_unicode>"

        Examples:
           | name           | new_name           | new_color  | new_emoji  | new_emoji_unicode |
           | Status account | My Primary Account | 7CDA00     | sunglasses | 1f60e             |

	@mayfail
    Scenario Outline: The user manages a watch only account
        When the user adds a watch only account "<address>" with "<name>" color "#<color>" and emoji "<emoji>" via "<add_via_context_menu>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>"
        When the user edits an account with "<name>" to "<new_name>" with color "#<new_color>" and emoji "<new_emoji>"
        Then the account is correctly displayed with "<new_name>" and "#<new_color>" and emoji unicode "<new_emoji_unicode>"
		When the user removes an account with name "<new_name>" and path "<path>" using password "<password>" and test cancel "yes"
		Then the account with "<new_name>" is not displayed

        Examples:
           | password | address                                    | path | name       | color  | emoji      | emoji_unicode | add_via_context_menu | new_name          | new_color  | new_emoji  | new_emoji_unicode |
           | N/A      | 0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A | N/A  | AccWatch_1 | 2946C4 | sunglasses | 1f60e         | yes                  | AccWatch_1_edited | 7CDA00     | thumbsup   | 1f44d             |
           | N/A      | 0xea123F7beFF45E3C9fdF54B324c29DBdA14a639B | N/A  | AccWatch_2 | D37EF4 | sunglasses | 1f60e         | no                   | AccWatch_2_edited | 26A69A     | thumbsup   | 1f44d             |

	##################################################################
	# The following 2 scenarions have to be executed one after another,
	# cause the second depends on the state made in the first one
	#
	# - Scenario Outline: The user manages a generated account
	# - Scenario Outline: The user manages a custom generated account
	##################################################################

	@mayfail
	Scenario Outline: The user manages a generated account
        When the user adds a generated account with "<name>" color "#<color>" and emoji "<emoji>" via "<add_via_context_menu>" using password "<password>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>"
        When the user edits an account with "<name>" to "<new_name>" with color "#<new_color>" and emoji "<new_emoji>"
        Then the account is correctly displayed with "<new_name>" and "#<new_color>" and emoji unicode "<new_emoji_unicode>"
		When the user removes an account with name "<new_name>" and path "<path>" using password "<password>" and test cancel "yes"
		Then the account with "<new_name>" is not displayed

        Examples:
           | password         | path             | name     | color  | emoji      | emoji_unicode | add_via_context_menu | new_name        | new_color  | new_emoji  | new_emoji_unicode |
           | TesTEr16843/!@00 | m/44'/60'/0'/0/1 | GenAcc_1 | 2946C4 | sunglasses | 1f60e         | yes                  | GenAcc_1_edited | 7CDA00     | thumbsup   | 1f44d             |
           | TesTEr16843/!@00 | m/44'/60'/0'/0/2 | GenAcc_2 | D37EF4 | sunglasses | 1f60e         | no                   | GenAcc_2_edited | 26A69A     | thumbsup   | 1f44d             |

	@mayfail
	Scenario Outline: The user manages a custom generated account
        When the user adds to "N/A" a custom generated account with "<name>" color "#<color>" and emoji "<emoji>" using password "<password>" and setting custom path index "<index>" or selecting address with "<order>" using "<is_ethereum_root>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>"
		When the user removes an account with name "<name>" and path "<path>" using password "<password>" and test cancel "no"
		Then the account with "<name>" is not displayed

        Examples:
           | is_ethereum_root | index | order | password         | path              | name           | color  | emoji      | emoji_unicode |
           | yes              | N/A   | N/A   | TesTEr16843/!@00 | m/44'/60'/0'/0/3  | CustomGenAcc_1 | 7CDA00 | sunglasses | 1f60e         |
           | yes              | 10    | N/A   | TesTEr16843/!@00 | m/44'/60'/0'/0/10 | CustomGenAcc_2 | D37EF4 | sunglasses | 1f60e         |
           | yes              | N/A   | 99    | TesTEr16843/!@00 | m/44'/60'/0'/0/99 | CustomGenAcc_3 | 26A69A | sunglasses | 1f60e         |
           | no               | 10    | N/A   | TesTEr16843/!@00 | m/44'/1'/0'/0/10  | CustomGenAcc_4 | D37EF4 | sunglasses | 1f60e         |
           | no               | N/A   | 99    | TesTEr16843/!@00 | m/44'/1'/0'/0/99  | CustomGenAcc_5 | 26A69A | sunglasses | 1f60e         |

	##################################################################

	@mayfail
	Scenario Outline: The user manages a private key imported account
	    When the user adds a private key account "<private_key>" with "<name>" color "#<color>" and emoji "<emoji>" using password "<password>" making keypair with name "<keypair_name>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>"
        When the user edits an account with "<name>" to "<new_name>" with color "#<new_color>" and emoji "<new_emoji>"
        Then the account is correctly displayed with "<new_name>" and "#<new_color>" and emoji unicode "<new_emoji_unicode>"
		When the user removes an account with name "<new_name>" and path "<path>" using password "<password>" and test cancel "no"
		Then the account with "<new_name>" is not displayed

		Examples:
           | password         | keypair_name      | private_key                                                      | path | name         | color  | emoji      | emoji_unicode | new_name            | new_color  | new_emoji  | new_emoji_unicode |
           | TesTEr16843/!@00 | PrivateKeyKeypair | 2daa36a3abe381a9c01610bf10fda272fbc1b8a22179a39f782c512346e3e470 | N/A  | PrivKeyAcc_1 | 2946C4 | sunglasses | 1f60e         | PrivKeyAcc_1_edited | 7CDA00     | thumbsup   | 1f44d             |

	@mayfail
	Scenario Outline: The user manages a seed phrase imported account
	    When the user adds an imported seed phrase account "<seed_phrase>" with "<name>" color "#<color>" and emoji "<emoji>" using password "<password>" making keypair with name "<keypair_name>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>"
        When the user edits an account with "<name>" to "<new_name>" with color "#<new_color>" and emoji "<new_emoji>"
        Then the account is correctly displayed with "<new_name>" and "#<new_color>" and emoji unicode "<new_emoji_unicode>"
        When the user removes an account with name "<new_name>" and path "<path>" using password "<password>" and test cancel "no"
		Then the account with "<name>" is not displayed

		Examples:
           | password         | keypair_name | path             | seed_phrase                                                                                                                                                   | name     | color  | emoji      | emoji_unicode | new_name        | new_color  | new_emoji  | new_emoji_unicode |
           | TesTEr16843/!@00 | SPKeyPair24	 | m/44'/60'/0'/0/0 | elite dinosaur flavor canoe garbage palace antique dolphin virtual mixed sand impact solution inmate hair pipe affair cage vote estate gloom lamp robust like | SPAcc_24 | 2946C4 | sunglasses | 1f60e         | SPAcc_24_edited | 7CDA00     | thumbsup   | 1f44d             |
           | TesTEr16843/!@00 | SPKeyPair18	 | m/44'/60'/0'/0/0 | kitten tiny cup admit cactus shrug shuffle accident century faith roof plastic beach police barely vacant sign blossom                                        | SPAcc_18 | 2946C4 | sunglasses | 1f60e         | SPAcc_18_edited | 7CDA00     | thumbsup   | 1f44d             |
           | TesTEr16843/!@00 | SPKeyPair12	 | m/44'/60'/0'/0/0 | pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial                                                                               | SPAcc_12 | 2946C4 | sunglasses | 1f60e         | SPAcc_12_edited | 7CDA00     | thumbsup   | 1f44d             |

	##################################################################
	# The following 2 scenarions have to be executed one after another,
	# cause the second depends on the state made in the first one
	#
	# - Scenario Outline: The user adds an account from the imported seed phrase
	# - Scenario Outline: The user manages an account created from the imported seed phrase
	##################################################################

	@mayfail
	Scenario Outline: The user adds an account from the imported seed phrase
	    When the user adds an imported seed phrase account "<seed_phrase>" with "<name>" color "#<color>" and emoji "<emoji>" using password "<password>" making keypair with name "<keypair_name>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>"

		Examples:
           | password         | keypair_name | path             | seed_phrase                                                                     | name     | color  | emoji      | emoji_unicode |
           | TesTEr16843/!@00 | SPKeyPair12	 | m/44'/60'/0'/0/0 | pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial | SPAcc_12 | 2946C4 | sunglasses | 1f60e         |

	@mayfail
	Scenario Outline: The user manages an account created from the imported seed phrase
    	When the user adds to "<keypair_name>" a custom generated account with "<name>" color "#<color>" and emoji "<emoji>" using password "<password>" and setting custom path index "<index>" or selecting address with "<order>" using "<is_ethereum_root>"
    	Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>"
		When the user removes an account with name "<name>" and path "<path>" using password "<password>" and test cancel "no"
		Then the account with "<name>" is not displayed

        Examples:
           | keypair_name | is_ethereum_root | index | order | password         | path              | name           | color  | emoji      | emoji_unicode |
           | SPKeyPair12  | yes              | N/A   | N/A   | TesTEr16843/!@00 | m/44'/60'/0'/0/1  | CustomGenAcc_1 | 7CDA00 | sunglasses | 1f60e         |
           | SPKeyPair12  | yes              | 10    | N/A   | TesTEr16843/!@00 | m/44'/60'/0'/0/10 | CustomGenAcc_2 | D37EF4 | sunglasses | 1f60e         |
           | SPKeyPair12  | yes              | N/A   | 99    | TesTEr16843/!@00 | m/44'/60'/0'/0/99 | CustomGenAcc_3 | 26A69A | sunglasses | 1f60e         |
           | SPKeyPair12  | no               | 10    | N/A   | TesTEr16843/!@00 | m/44'/1'/0'/0/10  | CustomGenAcc_4 | D37EF4 | sunglasses | 1f60e         |
           | SPKeyPair12  | no               | N/A   | 99    | TesTEr16843/!@00 | m/44'/1'/0'/0/99  | CustomGenAcc_5 | 26A69A | sunglasses | 1f60e         |

	##################################################################

	##################################################################
	# The following 2 scenarions have to be executed one after another,
	# cause the second depends on the state made in the first one
	#
	# - Scenario Outline: The user adds and edits an account from the generated seed phrase
	# - Scenario Outline: The user manages an account created from the generated seed phrase
	##################################################################

	@mayfail
	Scenario Outline: The user adds and edits an account from the generated seed phrase
	    When the user adds a generated seed phrase account with "<name>" color "#<color>" and emoji "<emoji>" using password "<password>" making keypair with name "<keypair_name>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>"
        When the user edits an account with "<name>" to "<new_name>" with color "#<new_color>" and emoji "<new_emoji>"
        Then the account is correctly displayed with "<new_name>" and "#<new_color>" and emoji unicode "<new_emoji_unicode>"

		Examples:
           | password         | keypair_name | name  | color  | emoji      | emoji_unicode | new_name     | new_color  | new_emoji  | new_emoji_unicode |
           | TesTEr16843/!@00 | SPKeyPair	 | SPAcc | 2946C4 | sunglasses | 1f60e         | SPAcc_edited | 7CDA00     | thumbsup   | 1f44d             |

	@mayfail
	Scenario Outline: The user manages an account created from the generated seed phrase
    	When the user adds to "<keypair_name>" a custom generated account with "<name>" color "#<color>" and emoji "<emoji>" using password "<password>" and setting custom path index "<index>" or selecting address with "<order>" using "<is_ethereum_root>"
    	Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>"
		When the user removes an account with name "<name>" and path "<path>" using password "<password>" and test cancel "no"
		Then the account with "<name>" is not displayed

        Examples:
           | keypair_name | is_ethereum_root | index | order | password         | path              | name           | color  | emoji      | emoji_unicode |
           | SPKeyPair    | yes              | N/A   | N/A   | TesTEr16843/!@00 | m/44'/60'/0'/0/1  | CustomGenAcc_1 | 7CDA00 | sunglasses | 1f60e         |
           | SPKeyPair    | yes              | 10    | N/A   | TesTEr16843/!@00 | m/44'/60'/0'/0/10 | CustomGenAcc_2 | D37EF4 | sunglasses | 1f60e         |
           | SPKeyPair    | yes              | N/A   | 99    | TesTEr16843/!@00 | m/44'/60'/0'/0/99 | CustomGenAcc_3 | 26A69A | sunglasses | 1f60e         |
           | SPKeyPair    | no               | 10    | N/A   | TesTEr16843/!@00 | m/44'/1'/0'/0/10  | CustomGenAcc_4 | D37EF4 | sunglasses | 1f60e         |
           | SPKeyPair    | no               | N/A   | 99    | TesTEr16843/!@00 | m/44'/1'/0'/0/99  | CustomGenAcc_5 | 26A69A | sunglasses | 1f60e         |
	##################################################################

	@mayfail
	Scenario: The user adds an account and then decides to use a Keycard
	    When the user adds new master key and go to use a Keycard
	    Then settings keycard section is opened