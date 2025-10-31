import unittest
import ../../src/app/modules/main/wallet_section/saved_addresses/model
import ../../src/app/modules/main/wallet_section/saved_addresses/item
import ../../src/app/modules/shared/qt_model_spy

suite "SavedAddressesModel - Granular Updates":
  
  setup:
    var model = newModel()
    var spy = newQtModelSpy()
  
  teardown:
    spy.disable()

  test "Empty model initialization":
    check model.getCount() == 0

  test "Insert addresses - bulk insert":
    spy.enable()
    
    let addresses = @[
      initItem("Alice", "0x1111", "0x1111", "alice.eth", "blue", false),
      initItem("Bob", "0x2222", "0x2222", "bob.eth", "red", false),
      initItem("Charlie", "0x3333", "0x3333", "", "green", false)
    ]
    
    model.setItems(addresses)
    
    # Verify bulk insert
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 2  # 3 items (0, 1, 2)
    
    check model.getCount() == 3
    spy.disable()

  test "Update addresses - same count":
    # Initial setup
    let initial = @[
      initItem("Alice", "0x1111", "0x1111", "alice.eth", "blue", false),
      initItem("Bob", "0x2222", "0x2222", "bob.eth", "red", false),
      initItem("Charlie", "0x3333", "0x3333", "", "green", false)
    ]
    model.setItems(initial)
    
    spy.enable()
    
    # Update: Change Alice's name and Bob's colorId
    let updated = @[
      initItem("Alice Updated", "0x1111", "0x1111", "alice.eth", "blue", false),
      initItem("Bob", "0x2222", "0x2222", "bob.eth", "yellow", false),
      initItem("Charlie", "0x3333", "0x3333", "", "green", false)
    ]
    
    model.setItems(updated)
    
    # Should have dataChanged calls for Alice (name) and Bob (colorId)
    check spy.countDataChanged() == 2
    
    # No inserts or removes
    check spy.countInserts() == 0
    check spy.countRemoves() == 0
    
    check model.getCount() == 3
    spy.disable()

  test "Remove addresses":
    # Initial setup
    let initial = @[
      initItem("Alice", "0x1111", "0x1111", "alice.eth", "blue", false),
      initItem("Bob", "0x2222", "0x2222", "bob.eth", "red", false),
      initItem("Charlie", "0x3333", "0x3333", "", "green", false)
    ]
    model.setItems(initial)
    
    spy.enable()
    
    # Remove Bob (middle item)
    let afterRemove = @[
      initItem("Alice", "0x1111", "0x1111", "alice.eth", "blue", false),
      initItem("Charlie", "0x3333", "0x3333", "", "green", false)
    ]
    
    model.setItems(afterRemove)
    
    # Should remove 1 item
    check spy.countRemoves() == 1
    
    check model.getCount() == 2
    spy.disable()

  test "Add new addresses":
    # Initial setup
    let initial = @[
      initItem("Alice", "0x1111", "0x1111", "alice.eth", "blue", false)
    ]
    model.setItems(initial)
    
    spy.enable()
    
    # Add two more addresses
    let afterAdd = @[
      initItem("Alice", "0x1111", "0x1111", "alice.eth", "blue", false),
      initItem("Bob", "0x2222", "0x2222", "bob.eth", "red", false),
      initItem("Charlie", "0x3333", "0x3333", "", "green", false)
    ]
    
    model.setItems(afterAdd)
    
    # Should insert 2 items
    check spy.countInserts() == 2
    
    check model.getCount() == 3
    spy.disable()

  test "Mixed operations - remove, update, add":
    # Initial: Alice, Bob, Charlie
    let initial = @[
      initItem("Alice", "0x1111", "0x1111", "alice.eth", "blue", false),
      initItem("Bob", "0x2222", "0x2222", "bob.eth", "red", false),
      initItem("Charlie", "0x3333", "0x3333", "", "green", false)
    ]
    model.setItems(initial)
    
    spy.enable()
    
    # New: Alice (updated name), David (new), Eve (new) - Bob and Charlie removed
    let mixed = @[
      initItem("Alice Updated", "0x1111", "0x1111", "alice.eth", "blue", false),
      initItem("David", "0x4444", "0x4444", "david.eth", "purple", false),
      initItem("Eve", "0x5555", "0x5555", "", "orange", false)
    ]
    
    model.setItems(mixed)
    
    # Should have removes (Bob, Charlie), updates (Alice), and inserts (David, Eve)
    check spy.countRemoves() == 2
    check spy.countDataChanged() >= 1  # Alice updated
    check spy.countInserts() == 2
    
    check model.getCount() == 3
    spy.disable()

  test "Large batch update - bulk operations efficiency":
    spy.enable()
    
    # Create 50 addresses
    var addresses: seq[Item]
    for i in 0..<50:
      addresses.add(initItem(
        "Address" & $i,
        "0x" & $i,
        "0x" & $i,
        "addr" & $i & ".eth",
        if i mod 2 == 0: "blue" else: "red",
        false
      ))
    
    model.setItems(addresses)
    
    # Should use bulk insert
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 49
    
    check model.getCount() == 50
    spy.disable()

  test "Test network addresses separate from mainnet":
    let addresses = @[
      initItem("Alice Mainnet", "0x1111", "0x1111", "alice.eth", "blue", false),
      initItem("Bob Testnet", "0x2222", "0x2222", "bob.eth", "red", true),
      initItem("Charlie Mainnet", "0x3333", "0x3333", "", "green", false)
    ]
    
    model.setItems(addresses)
    
    check model.getCount() == 3
    
    # Test getItemByAddress for mainnet
    let aliceItem = model.getItemByAddress("0x1111", false)
    check aliceItem.getName() == "Alice Mainnet"
    check not aliceItem.getIsTest()
    
    # Test getItemByAddress for testnet
    let bobItem = model.getItemByAddress("0x2222", true)
    check bobItem.getName() == "Bob Testnet"
    check bobItem.getIsTest()

  test "Update ENS names":
    # Start with addresses without ENS
    let initial = @[
      initItem("Alice", "0x1111", "0x1111", "", "blue", false),
      initItem("Bob", "0x2222", "0x2222", "", "red", false)
    ]
    model.setItems(initial)
    
    spy.enable()
    
    # Update with ENS names resolved
    let withEns = @[
      initItem("Alice", "0x1111", "0x1111", "alice.eth", "blue", false),
      initItem("Bob", "0x2222", "0x2222", "bob.eth", "red", false)
    ]
    
    model.setItems(withEns)
    
    # Should have dataChanged for ENS role updates
    check spy.countDataChanged() == 2
    
    spy.disable()

  test "Color changes":
    let initial = @[
      initItem("Alice", "0x1111", "0x1111", "alice.eth", "blue", false)
    ]
    model.setItems(initial)
    
    spy.enable()
    
    # Change color
    let updated = @[
      initItem("Alice", "0x1111", "0x1111", "alice.eth", "red", false)
    ]
    
    model.setItems(updated)
    
    # Should update colorId role
    check spy.countDataChanged() == 1
    let changes = spy.getDataChanged()
    check changes[0].topLeft == 0
    check changes[0].bottomRight == 0
    # Should only update ColorId role
    check ModelRole.ColorId.int in changes[0].roles
    
    spy.disable()
