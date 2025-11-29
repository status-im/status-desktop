import unittest
import ../../src/app/modules/shared_models/member_model
import ../../src/app/modules/shared_models/member_item
import ../../src/app/modules/shared/qt_model_spy
import ../../src/app_service/common/types

# Test suite for MemberModel with model_sync optimization

proc createTestMember(id: int, role: MemberRole = MemberRole.None): MemberItem =
  initMemberItem(
    pubKey = "0xmember" & $id,
    displayName = "Member" & $id,
    usesDefaultName = false,
    ensName = "",
    isEnsVerified = false,
    localNickname = "",
    alias = "alias" & $id,
    icon = "",
    colorId = id,
    onlineStatus = OnlineStatus.Inactive,
    isCurrentUser = false,
    isContact = false,
    trustStatus = TrustStatus.Unknown,
    isBlocked = false,
    contactRequest = ContactRequest.None,
    memberRole = role,
    joined = true,
    requestToJoinId = "",
    requestToJoinLoading = false,
    airdropAddress = "",
    membershipRequestState = MembershipRequestState.None
  )

suite "MemberModel - Granular Updates":
  
  test "Empty model initialization":
    var model = newModel()
    check model.getCount() == 0
  
  test "Insert members into empty model - bulk insert":
    var model = newModel()
    var spy = newQtModelSpy()
    spy.enable()
    
    var items: seq[MemberItem] = @[]
    for i in 1..5:
      items.add(createTestMember(i))
    
    model.setItems(items)
    
    check model.getCount() == 5
    
    # Verify Qt signals - BULK insert!
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 4  # All 5 members in one call!
    
    spy.disable()
  
  test "Update member roles - bulk dataChanged":
    var model = newModel()
    var spy = newQtModelSpy()
    
    # Setup initial members
    var initialItems: seq[MemberItem] = @[]
    for i in 1..10:
      initialItems.add(createTestMember(i, MemberRole.None))
    
    model.setItems(initialItems)
    check model.getCount() == 10
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Update all members - change role to Admin
    var updatedItems: seq[MemberItem] = @[]
    for i in 1..10:
      updatedItems.add(createTestMember(i, MemberRole.Admin))
    
    model.setItems(updatedItems)
    
    check model.getCount() == 10
    
    # Verify Qt signals - BULK dataChanged!
    check spy.countDataChanged() == 1
    let changes = spy.getDataChanged()
    check changes[0].topLeft == 0
    check changes[0].bottomRight == 9  # All 10 members!
    
    spy.disable()
  
  test "Remove members - non-consecutive":
    var model = newModel()
    var spy = newQtModelSpy()
    
    # Setup 10 members
    var initialItems: seq[MemberItem] = @[]
    for i in 1..10:
      initialItems.add(createTestMember(i))
    
    model.setItems(initialItems)
    check model.getCount() == 10
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Remove members 2, 5, 8 (non-consecutive)
    var updatedItems: seq[MemberItem] = @[]
    for i in [1, 3, 4, 6, 7, 9, 10]:
      updatedItems.add(initialItems[i-1])
    
    model.setItems(updatedItems)
    
    check model.getCount() == 7
    
    # Verify Qt signals - 3 separate removes
    check spy.countRemoves() == 3
    
    spy.disable()
  
  test "Large community member list - 100 members":
    var model = newModel()
    var spy = newQtModelSpy()
    
    # Create 100 members
    var initialItems: seq[MemberItem] = @[]
    for i in 1..100:
      initialItems.add(createTestMember(i, MemberRole.None))
    
    model.setItems(initialItems)
    check model.getCount() == 100
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Update all members - change online status
    var updatedItems: seq[MemberItem] = @[]
    for i in 1..100:
      var member = createTestMember(i, MemberRole.None)
      # Can't modify onlineStatus directly with initMemberItem
      # so we'll use the same member but model will detect no changes
      # Let's change the role instead
      updatedItems.add(createTestMember(i, MemberRole.TokenMaster))
    
    model.setItems(updatedItems)
    
    check model.getCount() == 100
    
    # PROOF: 100 updates = 1 dataChanged call!
    echo "\n=== MEMBER MODEL BULK PROOF ==="
    echo "Updated 100 members, dataChanged calls: ", spy.countDataChanged()
    check spy.countDataChanged() == 1
    
    let changes = spy.getDataChanged()
    check changes[0].topLeft == 0
    check changes[0].bottomRight == 99
    
    spy.disable()
  
  test "Mixed operations - add admin, remove member, update others":
    var model = newModel()
    var spy = newQtModelSpy()
    
    # Setup 5 members
    var initialItems: seq[MemberItem] = @[]
    for i in 1..5:
      initialItems.add(createTestMember(i, MemberRole.None))
    
    model.setItems(initialItems)
    check model.getCount() == 5
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Mixed operations:
    # - Keep members 1, 2
    # - Update member 3 (change role)
    # - Remove member 4
    # - Keep member 5
    # - Add new member 6
    var updatedItems: seq[MemberItem] = @[
      initialItems[0],  # Member 1 - no change
      initialItems[1],  # Member 2 - no change
      createTestMember(3, MemberRole.Admin),  # Member 3 - updated
      initialItems[4],  # Member 5 - no change
      createTestMember(6, MemberRole.None)  # Member 6 - new
    ]
    
    model.setItems(updatedItems)
    
    check model.getCount() == 5
    
    # Verify Qt signals - mixed operations
    check spy.countRemoves() == 1  # Member 4 removed
    check spy.countDataChanged() == 1  # Member 3 updated
    check spy.countInserts() == 1  # Member 6 added
    
    spy.disable()

when isMainModule:
  echo "Running MemberModel tests..."

