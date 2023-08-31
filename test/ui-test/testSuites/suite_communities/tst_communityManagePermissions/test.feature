Feature: Community Permissions

Background:
	Given A first time user lands on the status desktop and generates new key
	And the user signs up with username "tester123" and password "TesTEr16843/!@00"
	And the user lands on the signed in app
	And the user opens the community portal section
    And the user lands on the community portal section
    And the user creates a community named "Test-Community", with description "My community description", intro "Community Intro" and outro "Community Outro"
    And the user lands on the community named "Test-Community"


 Scenario: Permissions welcome screen content validation
    When "Manage Community" is clicked in the community sidebar
    And "Permissions" section is selected
    Then the welcome "Permissions" image is present
    And the welcome "Permissions" title is present
    And the welcome "Permissions" subtitle is present
    And the welcome "Permissions" settings "<user onboarding checklist>" is present
   	| Give individual members access to private channels |
    | Monetise your community with subscriptions and fees |
    | Require holding a token or NFT to obtain exclusive membership rights |
    And "Add new permission" button is present


  Scenario Outline: Adding permissions
    When "Manage Community" is clicked in the community sidebar
    And "Permissions" section is selected
    And the user adds new permission with anyone checkbox "<state>", holds "<first_asset>" and "<second_asset>" in amount "<amount>" and "<allowed_to>" "<in_general>"
    Then created permission with "<asset_title>" and "<second_asset_title>" and "<allowed_to_title>" is on permission page
    Examples:
      |state| first_asset   |  second_asset  | amount | allowed_to    |in_general     |asset_title | second_asset_title|allowed_to_title  |
      |On   | Dai Stablecoin|  No            | 10     | becomeMember  |No             |10 DAI      | No                |Become member     |
      |On   | Ether         |  No            | 1      | becomeAdmin   |No             |1 ETH       | No                |Become an admin   |
      |On   | Ether         |  Dai Stablecoin| 10     | viewAndPost   |#general       |10 ETH      | 10 DAI            |View and post     |
      |On   | Ether         |  Dai Stablecoin| 10     | viewOnly      |#general       |10 ETH      | 10 DAI            |View only         |
      |Off  | No            |  No            | No     | becomeAdmin   |No             |No          | No                |Become an admin   |
