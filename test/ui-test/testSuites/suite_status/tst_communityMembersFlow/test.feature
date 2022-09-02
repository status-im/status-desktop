Feature: Status Desktop Community Members

	As a user I want to use community chat functionality.

  Background:

       Given the user starts the application with a specific data folder ../../../fixtures/community_members

    @mayfail
    Scenario: As an admin of comminty i want to be able block and unblock members
       When the user logs in with password TesTEr16843/!@00
       Then the user lands on the signed in app
       When the user opens the community named MyFriends
       Then the user blocks member with name Bobby
       And the user can see that Bobby was blocked
       Then the user unblocks member with name Bobby
       And the user can see that Bobby was unblocked