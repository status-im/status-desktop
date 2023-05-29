Feature: Community -> Manage Community

Background:
	Given A first time user lands on the status desktop and generates new key
	And the user signs up with username "tester123" and password "TesTEr16843/!@00"
	And the user lands on the signed in app
	And the user opens the community portal section
    And the user lands on the community portal section
    And the user creates a community named "Test-Community", with description "My community description", intro "Community Intro" and outro "Community Outro"
    And the user lands on the community named "Test-Community"


 Scenario: Manage community has Overview, Members, Permissions, Mint Tokens and Airdrops options
   When "Manage Community" is clicked in the community sidebar
   Then "<settings section>" should be an available option in Community->Manage->left navigation
   	| Overview   |
   	| Members    |
   	| Permissions|
   	| Mint Tokens|
   	| Airdrops   |

 Scenario Outline: Manage community -> Overview: community admin edits the community name, description and color
   When the admin renames the community to "<new_community_name>" and description to "<new_community_description>" and color to "<new_community_color>"
   Then the community overview name is "<new_community_name>"
   And the community overview description is "<new_community_description>"
   And the community overview color is "<new_community_color>"
   When the admin goes back to the community
   Then the user lands on the community named "<new_community_name>"
   Examples:
     | new_community_name       | new_community_description  | new_community_color |
     | myCommunityNamedChanged  | Cool new description 123   | #ff0000             |