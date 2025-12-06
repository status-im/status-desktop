import unittest
import ../../src/app/modules/shared_models/user_model
import ../../src/app/modules/shared_models/user_item
import ../../src/app/modules/shared/qt_model_spy
import ../../src/app_service/common/types

# Test suite for UserModel with model_sync optimization
# Verifies actual Qt model signals using spy

suite "UserModel - Granular Updates":
  
  test "Empty model initialization":
    var model = newModel()
    check model.getCount() == 0
  
  test "Insert users into empty model":
    var model = newModel()
    var spy = newQtModelSpy()
    spy.enable()
    
    # Create 3 test users
    var items: seq[UserItem] = @[]
    for i in 1..3:
      var user = UserItem()
      user.setup(
        pubKey = "0xabc" & $i,
        displayName = "User" & $i,
        usesDefaultName = false,
        ensName = "",
        isEnsVerified = false,
        localNickname = "",
        alias = "alias" & $i,
        icon = "",
        colorId = i,
        onlineStatus = OnlineStatus.Inactive,
        isContact = false,
        isBlocked = false,
        contactRequest = ContactRequest.None,
        isCurrentUser = false,
        lastUpdated = 0,
        lastUpdatedLocally = 0,
        bio = "",
        thumbnailImage = "",
        largeImage = "",
        isContactRequestReceived = false,
        isContactRequestSent = false,
        isRemoved = false,
        trustStatus = TrustStatus.Untrustworthy
      )
      items.add(user)
    
    model.setItems(items)
    
    # Verify model state
    check model.getCount() == 3
    
    # Verify Qt signals - BULK insert!
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 2  # All 3 users in one call!
    
    spy.disable()
  
  test "Update existing users - bulk dataChanged":
    var model = newModel()
    var spy = newQtModelSpy()
    
    # Setup initial state
    var initialItems: seq[UserItem] = @[]
    for i in 1..5:
      var user = UserItem()
      user.setup(
        pubKey = "0xabc" & $i,
        displayName = "User" & $i,
        usesDefaultName = false,
        ensName = "",
        isEnsVerified = false,
        localNickname = "",
        alias = "alias" & $i,
        icon = "",
        colorId = i,
        onlineStatus = OnlineStatus.Inactive,
        isContact = false,
        isBlocked = false,
        contactRequest = ContactRequest.None,
        isCurrentUser = false,
        lastUpdated = 0,
        lastUpdatedLocally = 0,
        bio = "",
        thumbnailImage = "",
        largeImage = "",
        isContactRequestReceived = false,
        isContactRequestSent = false,
        isRemoved = false,
        trustStatus = TrustStatus.Untrustworthy
      )
      initialItems.add(user)
    
    model.setItems(initialItems)
    check model.getCount() == 5
    
    # Enable spy and clear setup signals
    spy.enable()
    spy.clear()
    
    # Update all users - change online status
    var updatedItems: seq[UserItem] = @[]
    for i in 1..5:
      var user = UserItem()
      user.setup(
        pubKey = "0xabc" & $i,
        displayName = "User" & $i,
        usesDefaultName = false,
        ensName = "",
        isEnsVerified = false,
        localNickname = "",
        alias = "alias" & $i,
        icon = "",
        colorId = i,
        onlineStatus = OnlineStatus.Online,  # Changed!
        isContact = false,
        isBlocked = false,
        contactRequest = ContactRequest.None,
        isCurrentUser = false,
        lastUpdated = 0,
        lastUpdatedLocally = 0,
        bio = "",
        thumbnailImage = "",
        largeImage = "",
        isContactRequestReceived = false,
        isContactRequestSent = false,
        isRemoved = false,
        trustStatus = TrustStatus.Untrustworthy
      )
      updatedItems.add(user)
    
    model.setItems(updatedItems)
    
    # Verify state
    check model.getCount() == 5
    
    # Verify Qt signals - BULK dataChanged!
    check spy.countDataChanged() == 1  # Only 1 call for 5 updates!
    let changes = spy.getDataChanged()
    check changes[0].topLeft == 0
    check changes[0].bottomRight == 4  # All 5 users!
    
    spy.disable()
  
  test "Remove users":
    var model = newModel()
    var spy = newQtModelSpy()
    
    # Setup 5 users
    var initialItems: seq[UserItem] = @[]
    for i in 1..5:
      var user = UserItem()
      user.setup(
        pubKey = "0xabc" & $i,
        displayName = "User" & $i,
        usesDefaultName = false,
        ensName = "",
        isEnsVerified = false,
        localNickname = "",
        alias = "alias" & $i,
        icon = "",
        colorId = i,
        onlineStatus = OnlineStatus.Inactive,
        isContact = false,
        isBlocked = false,
        contactRequest = ContactRequest.None,
        isCurrentUser = false,
        lastUpdated = 0,
        lastUpdatedLocally = 0,
        bio = "",
        thumbnailImage = "",
        largeImage = "",
        isContactRequestReceived = false,
        isContactRequestSent = false,
        isRemoved = false,
        trustStatus = TrustStatus.Untrustworthy
      )
      initialItems.add(user)
    
    model.setItems(initialItems)
    check model.getCount() == 5
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Remove users 2 and 4 (non-consecutive)
    var updatedItems: seq[UserItem] = @[
      initialItems[0],  # User 1
      initialItems[2],  # User 3
      initialItems[4]   # User 5
    ]
    
    model.setItems(updatedItems)
    
    # Verify state
    check model.getCount() == 3
    
    # Verify Qt signals - 2 separate removes
    check spy.countRemoves() == 2
    
    spy.disable()
  
  test "Large batch update - 50 users":
    var model = newModel()
    var spy = newQtModelSpy()
    
    # Create 50 users
    var initialItems: seq[UserItem] = @[]
    for i in 1..50:
      var user = UserItem()
      user.setup(
        pubKey = "0xabc" & $i,
        displayName = "User" & $i,
        usesDefaultName = false,
        ensName = "",
        isEnsVerified = false,
        localNickname = "",
        alias = "alias" & $i,
        icon = "",
        colorId = i mod 10,
        onlineStatus = OnlineStatus.Inactive,
        isContact = false,
        isBlocked = false,
        contactRequest = ContactRequest.None,
        isCurrentUser = false,
        lastUpdated = 0,
        lastUpdatedLocally = 0,
        bio = "",
        thumbnailImage = "",
        largeImage = "",
        isContactRequestReceived = false,
        isContactRequestSent = false,
        isRemoved = false,
        trustStatus = TrustStatus.Untrustworthy
      )
      initialItems.add(user)
    
    model.setItems(initialItems)
    check model.getCount() == 50
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Update all users - change to online
    var updatedItems: seq[UserItem] = @[]
    for i in 1..50:
      var user = UserItem()
      user.setup(
        pubKey = "0xabc" & $i,
        displayName = "User" & $i,
        usesDefaultName = false,
        ensName = "",
        isEnsVerified = false,
        localNickname = "",
        alias = "alias" & $i,
        icon = "",
        colorId = i mod 10,
        onlineStatus = OnlineStatus.Online,  # Changed!
        isContact = false,
        isBlocked = false,
        contactRequest = ContactRequest.None,
        isCurrentUser = false,
        lastUpdated = 0,
        lastUpdatedLocally = 0,
        bio = "",
        thumbnailImage = "",
        largeImage = "",
        isContactRequestReceived = false,
        isContactRequestSent = false,
        isRemoved = false,
        trustStatus = TrustStatus.Untrustworthy
      )
      updatedItems.add(user)
    
    model.setItems(updatedItems)
    
    # Verify state
    check model.getCount() == 50
    
    # PROOF: 50 updates = 1 dataChanged call!
    echo "\n=== USER MODEL BULK PROOF ==="
    echo "Updated 50 users, dataChanged calls: ", spy.countDataChanged()
    check spy.countDataChanged() == 1
    
    let changes = spy.getDataChanged()
    check changes[0].topLeft == 0
    check changes[0].bottomRight == 49
    
    spy.disable()

when isMainModule:
  echo "Running UserModel tests..."

