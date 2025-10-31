import unittest
import ../../src/app/modules/shared_models/collectible_ownership_model
import ../../src/backend/collectibles_types
import ../../src/app/modules/shared/qt_model_spy
import stint

suite "CollectibleOwnershipModel - Granular Updates":
  
  setup:
    var model = newOwnershipModel()
    var spy = newQtModelSpy()
  
  teardown:
    spy.disable()

  test "Empty model initialization":
    check model.getCount() == 0

  test "Insert ownerships - bulk insert":
    spy.enable()
    
    var ownerships: seq[AccountBalance]
    ownerships.add(AccountBalance(address: "0x1111", balance: u256(10), txTimestamp: 1000))
    ownerships.add(AccountBalance(address: "0x2222", balance: u256(20), txTimestamp: 2000))
    ownerships.add(AccountBalance(address: "0x3333", balance: u256(5), txTimestamp: 3000))
    
    model.setItems(ownerships)
    
    # Verify bulk insert
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 2  # 3 items (0, 1, 2)
    
    check model.getCount() == 3
    spy.disable()

  test "Update ownerships - balance changes":
    # Initial setup
    var initial: seq[AccountBalance]
    initial.add(AccountBalance(address: "0x1111", balance: u256(10), txTimestamp: 1000))
    initial.add(AccountBalance(address: "0x2222", balance: u256(20), txTimestamp: 2000))
    initial.add(AccountBalance(address: "0x3333", balance: u256(5), txTimestamp: 3000))
    model.setItems(initial)
    
    spy.enable()
    
    # Update: Change balances for 0x1111 and 0x3333
    var updated: seq[AccountBalance]
    updated.add(AccountBalance(address: "0x1111", balance: u256(15), txTimestamp: 1000))  # balance +5
    updated.add(AccountBalance(address: "0x2222", balance: u256(20), txTimestamp: 2000))  # unchanged
    updated.add(AccountBalance(address: "0x3333", balance: u256(8), txTimestamp: 3000))   # balance +3
    
    model.setItems(updated)
    
    # Should have dataChanged calls for 0x1111 and 0x3333
    check spy.countDataChanged() == 2
    
    # No inserts or removes
    check spy.countInserts() == 0
    check spy.countRemoves() == 0
    
    check model.getCount() == 3
    spy.disable()

  test "Remove ownership":
    # Initial setup
    var initial: seq[AccountBalance]
    initial.add(AccountBalance(address: "0x1111", balance: u256(10), txTimestamp: 1000))
    initial.add(AccountBalance(address: "0x2222", balance: u256(20), txTimestamp: 2000))
    initial.add(AccountBalance(address: "0x3333", balance: u256(5), txTimestamp: 3000))
    model.setItems(initial)
    
    spy.enable()
    
    # Remove 0x2222 (middle item)
    var afterRemove: seq[AccountBalance]
    afterRemove.add(AccountBalance(address: "0x1111", balance: u256(10), txTimestamp: 1000))
    afterRemove.add(AccountBalance(address: "0x3333", balance: u256(5), txTimestamp: 3000))
    
    model.setItems(afterRemove)
    
    # Should remove 1 item
    check spy.countRemoves() == 1
    
    check model.getCount() == 2
    spy.disable()

  test "Add new ownership":
    # Initial setup
    var initial: seq[AccountBalance]
    initial.add(AccountBalance(address: "0x1111", balance: u256(10), txTimestamp: 1000))
    model.setItems(initial)
    
    spy.enable()
    
    # Add two more ownerships
    var afterAdd: seq[AccountBalance]
    afterAdd.add(AccountBalance(address: "0x1111", balance: u256(10), txTimestamp: 1000))
    afterAdd.add(AccountBalance(address: "0x2222", balance: u256(20), txTimestamp: 2000))
    afterAdd.add(AccountBalance(address: "0x3333", balance: u256(5), txTimestamp: 3000))
    
    model.setItems(afterAdd)
    
    # Should insert 2 items in 1 bulk operation
    check spy.countInserts() == 1
    
    check model.getCount() == 3
    spy.disable()

  test "Large batch update - bulk operations efficiency":
    spy.enable()
    
    # Create 30 ownerships
    var ownerships: seq[AccountBalance]
    for i in 0..<30:
      ownerships.add(AccountBalance(
        address: "0x" & $i,
        balance: u256(i * 10),
        txTimestamp: 1000 + i
      ))
    
    model.setItems(ownerships)
    
    # Should use bulk insert
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 29
    
    check model.getCount() == 30
    spy.disable()

  test "getBalance helper function":
    var ownerships: seq[AccountBalance]
    ownerships.add(AccountBalance(address: "0xAAaa", balance: u256(10), txTimestamp: 1000))
    ownerships.add(AccountBalance(address: "0xBBBB", balance: u256(20), txTimestamp: 2000))
    ownerships.add(AccountBalance(address: "0xCCCC", balance: u256(5), txTimestamp: 3000))
    model.setItems(ownerships)
    
    # Test balance lookup (case insensitive)
    let balance1 = model.getBalance("0xaaaa")  # lowercase
    check balance1 == u256(10)
    
    let balance2 = model.getBalance("0xBBBB")  # exact case
    check balance2 == u256(20)
    
    let balance3 = model.getBalance("0xcccc")  # lowercase
    check balance3 == u256(5)
    
    # Non-existent address
    let balance4 = model.getBalance("0xDDDD")
    check balance4 == u256(0)

  test "Timestamp updates":
    # Start with ownership
    var initial: seq[AccountBalance]
    initial.add(AccountBalance(address: "0x1111", balance: u256(10), txTimestamp: 1000))
    model.setItems(initial)
    
    spy.enable()
    
    # Update timestamp (e.g., newer transaction)
    var updated: seq[AccountBalance]
    updated.add(AccountBalance(address: "0x1111", balance: u256(10), txTimestamp: 2000))
    
    model.setItems(updated)
    
    # Should have dataChanged for timestamp update
    check spy.countDataChanged() == 1
    
    spy.disable()

  test "Mixed operations - remove, update, add":
    # Initial: 0x1111, 0x2222, 0x3333
    var initial: seq[AccountBalance]
    initial.add(AccountBalance(address: "0x1111", balance: u256(10), txTimestamp: 1000))
    initial.add(AccountBalance(address: "0x2222", balance: u256(20), txTimestamp: 2000))
    initial.add(AccountBalance(address: "0x3333", balance: u256(5), txTimestamp: 3000))
    model.setItems(initial)
    
    spy.enable()
    
    # New: 0x1111 (updated balance), 0x4444 (new), 0x5555 (new) - 0x2222 and 0x3333 removed
    var mixed: seq[AccountBalance]
    mixed.add(AccountBalance(address: "0x1111", balance: u256(15), txTimestamp: 1000))
    mixed.add(AccountBalance(address: "0x4444", balance: u256(30), txTimestamp: 4000))
    mixed.add(AccountBalance(address: "0x5555", balance: u256(25), txTimestamp: 5000))
    
    model.setItems(mixed)
    
    # Should have bulk removes (0x2222, 0x3333), updates (0x1111), and bulk inserts (0x4444, 0x5555)
    check spy.countRemoves() == 1  # Bulk remove of 2 items
    check spy.countDataChanged() >= 1  # 0x1111 updated
    check spy.countInserts() == 1  # Bulk insert of 2 items
    
    check model.getCount() == 3
    spy.disable()

  test "Large balance values":
    var ownerships: seq[AccountBalance]
    # Test with very large u256 values
    ownerships.add(AccountBalance(
      address: "0x1111",
      balance: u256("1000000000000000000"),  # 1 ETH in wei
      txTimestamp: 1000
    ))
    ownerships.add(AccountBalance(
      address: "0x2222",
      balance: u256("999999999999999999999999"),  # Very large value
      txTimestamp: 2000
    ))
    
    model.setItems(ownerships)
    
    check model.getCount() == 2
    
    # Verify balances are stored correctly
    let balance1 = model.getBalance("0x1111")
    check balance1 == u256("1000000000000000000")
