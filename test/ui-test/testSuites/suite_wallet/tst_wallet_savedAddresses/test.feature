Feature: Wallet -> Saved addresses Management


Background:
    Given A first time user lands on the status desktop and generates new key
	And the user signs up with username "tester123" and password "TesTEr16843/!@00"
	And the user lands on the signed in app
    And the user opens the wallet section
    And the user accepts the signing phrase

    Scenario Outline: The user can manage a saved address
        When the user adds a saved address named "<name>" and address "<address>"
        And the user edits a saved address with name "<name>" to "<new_name>"
        Then the name "<new_name>" is in the list of saved addresses
        When the user deletes the saved address with name "<new_name>"
        Then the name "<new_name>" is not in the list of saved addresses
        When the user adds a saved address named "<name>" and ENS name "<ens_name>"
        Then the name "<name>" is in the list of saved addresses
        # Test for toggling favourite button is disabled until favourite functionality is enabled
        # When the user adds a saved address named "<name>" and address "<address>"
        # And the user toggles favourite for the saved address with name "<name>"
        # Then the saved address "<name>" has favourite status "true"
        Examples:
            | name | address                                    | new_name | ens_name |
            | bar  | 0x8397bc3c5a60a1883174f722403d63a8833312b7 | foo      | status.eth |
     # TODO: add saved address with all the networks
     # TODO: actions from burger menu
     # TODO: split the scenario above to several (exlude delete i think)
     # TODO: enhance edit actions to change networks
     # TODO: test for Share button