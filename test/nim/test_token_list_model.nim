import unittest
import ../../src/app/modules/shared_models/token_list_model
import ../../src/app/modules/shared_models/token_list_item
import ../../src/app/modules/shared/qt_model_spy

# Test suite for TokenListModel with model_sync optimization
# These tests verify the actual Qt model signals using a spy

suite "TokenListModel - Granular Updates":
  
  test "Empty model initialization":
    var model = newTokenListModel()
    check model.items.len == 0
  
  test "Insert items into empty model":
    var model = newTokenListModel()
    var spy = newQtModelSpy()
    spy.enable()
    
    # Start with empty model
    check model.items.len == 0
    
    # Add 3 items
    let items = @[
      initTokenListItem("key1", "Token A", "TKA", "#FF0000", "img1", 1, "", "1000", false, 18, 0),
      initTokenListItem("key2", "Token B", "TKB", "#00FF00", "img2", 1, "", "2000", false, 18, 0),
      initTokenListItem("key3", "Token C", "TKC", "#0000FF", "img3", 1, "", "3000", false, 18, 0),
    ]
    
    model.setItems(items)
    
    # Verify model state
    check model.items.len == 3
    check model.items[0].getSymbol() == "TKA"
    check model.items[1].getSymbol() == "TKB"
    check model.items[2].getSymbol() == "TKC"
    
    # Verify Qt signals (BULK operation - single call!)
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 2  # Bulk insert of 3 items!
    
    spy.disable()
  
  test "Update existing items - same count":
    var model = newTokenListModel()
    var spy = newQtModelSpy()
    
    # Setup initial state
    let initialItems = @[
      initTokenListItem("key1", "Token A", "TKA", "#FF0000", "img1", 1, "", "1000", false, 18, 0),
      initTokenListItem("key2", "Token B", "TKB", "#00FF00", "img2", 1, "", "2000", false, 18, 0),
      initTokenListItem("key3", "Token C", "TKC", "#0000FF", "img3", 1, "", "3000", false, 18, 0),
    ]
    model.setItems(initialItems)
    check model.items.len == 3
    
    # Enable spy and clear initial setup signals
    spy.enable()
    spy.clear()
    
    # Update items (change supply values)
    let updatedItems = @[
      initTokenListItem("key1", "Token A", "TKA", "#FF0000", "img1", 1, "", "1500", false, 18, 0),  # Supply changed
      initTokenListItem("key2", "Token B", "TKB", "#00FF00", "img2", 1, "", "2500", false, 18, 0),  # Supply changed
      initTokenListItem("key3", "Token C", "TKC", "#0000FF", "img3", 1, "", "3500", false, 18, 0),  # Supply changed
    ]
    
    model.setItems(updatedItems)
    
    # Verify state
    check model.items.len == 3
    let item1 = model.getItem("TKA")
    check item1.getSupply() == "1500"
    
    # Verify Qt signals - BULK dataChanged!
    check spy.countDataChanged() == 1  # Only ONE call!
    let changes = spy.getDataChanged()
    check changes[0].topLeft == 0
    check changes[0].bottomRight == 2  # All 3 items in single call!
    # Verify Supply role is present
    check changes[0].roles.len > 0
    
    spy.disable()
  
  test "Remove items":
    var model = newTokenListModel()
    var spy = newQtModelSpy()
    
    # Setup initial state with 5 items
    let initialItems = @[
      initTokenListItem("key1", "Token A", "TKA", "#FF0000", "img1", 1, "", "1000", false, 18, 0),
      initTokenListItem("key2", "Token B", "TKB", "#00FF00", "img2", 1, "", "2000", false, 18, 0),
      initTokenListItem("key3", "Token C", "TKC", "#0000FF", "img3", 1, "", "3000", false, 18, 0),
      initTokenListItem("key4", "Token D", "TKD", "#FFFF00", "img4", 1, "", "4000", false, 18, 0),
      initTokenListItem("key5", "Token E", "TKE", "#FF00FF", "img5", 1, "", "5000", false, 18, 0),
    ]
    model.setItems(initialItems)
    check model.items.len == 5
    
    # Enable spy and clear initial setup
    spy.enable()
    spy.clear()
    
    # Remove items B and D (non-consecutive)
    let updatedItems = @[
      initTokenListItem("key1", "Token A", "TKA", "#FF0000", "img1", 1, "", "1000", false, 18, 0),
      initTokenListItem("key3", "Token C", "TKC", "#0000FF", "img3", 1, "", "3000", false, 18, 0),
      initTokenListItem("key5", "Token E", "TKE", "#FF00FF", "img5", 1, "", "5000", false, 18, 0),
    ]
    
    model.setItems(updatedItems)
    
    # Verify state
    check model.items.len == 3
    check model.hasItem("TKA", "")
    check not model.hasItem("TKB", "")
    check model.hasItem("TKC", "")
    check not model.hasItem("TKD", "")
    check model.hasItem("TKE", "")
    
    # Verify Qt signals - 2 remove operations (non-consecutive)
    check spy.countRemoves() == 2
    let removes = spy.getRemoves()
    # Removes happen in reverse order to maintain indices
    check removes[0].first == 3  # Remove TKD first
    check removes[0].last == 3
    check removes[1].first == 1  # Then remove TKB (adjusted index)
    check removes[1].last == 1
    
    spy.disable()
  
  test "Mixed operations - insert, update, remove":
    var model = newTokenListModel()
    var spy = newQtModelSpy()
    
    # Setup initial state
    let initialItems = @[
      initTokenListItem("key1", "Token A", "TKA", "#FF0000", "img1", 1, "", "1000", false, 18, 0),
      initTokenListItem("key2", "Token B", "TKB", "#00FF00", "img2", 1, "", "2000", false, 18, 0),
      initTokenListItem("key3", "Token C", "TKC", "#0000FF", "img3", 1, "", "3000", false, 18, 0),
    ]
    model.setItems(initialItems)
    check model.items.len == 3
    
    # Enable spy and clear initial setup
    spy.enable()
    spy.clear()
    
    # Apply mixed operations:
    # - Keep TKA (no change)
    # - Update TKB (supply change)
    # - Remove TKC
    # - Add TKD (new)
    let updatedItems = @[
      initTokenListItem("key1", "Token A", "TKA", "#FF0000", "img1", 1, "", "1000", false, 18, 0),  # No change
      initTokenListItem("key2", "Token B", "TKB", "#00FF00", "img2", 1, "", "2500", false, 18, 0),  # Updated
      initTokenListItem("key4", "Token D", "TKD", "#FFFF00", "img4", 1, "", "4000", false, 18, 0),  # New
    ]
    
    model.setItems(updatedItems)
    
    # Verify state
    check model.items.len == 3
    check model.hasItem("TKA", "")
    check model.hasItem("TKB", "")
    check not model.hasItem("TKC", "")
    check model.hasItem("TKD", "")
    
    let itemB = model.getItem("TKB")
    check itemB.getSupply() == "2500"
    
    # Verify Qt signals - mixed operations
    check spy.countRemoves() == 1  # Remove TKC
    check spy.countDataChanged() == 1  # Update TKB
    check spy.countInserts() == 1  # Insert TKD
    
    let removes = spy.getRemoves()
    check removes[0].first == 2  # TKC at index 2
    
    let changes = spy.getDataChanged()
    check changes[0].topLeft == 1  # TKB at index 1
    check changes[0].bottomRight == 1
    
    let inserts = spy.getInserts()
    check inserts[0].first == 2  # TKD inserted at index 2 (after remove)
    
    spy.disable()
  
  test "Large batch update - bulk operations efficiency":
    var model = newTokenListModel()
    var spy = newQtModelSpy()
    
    # Create 100 initial items
    var initialItems: seq[TokenListItem] = @[]
    for i in 0..<100:
      initialItems.add(initTokenListItem(
        "key" & $i,
        "Token " & $i,
        "TK" & $i,
        "#FF0000",
        "img" & $i,
        1,
        "",
        $1000,
        false,
        18,
        0
      ))
    
    model.setItems(initialItems)
    check model.items.len == 100
    
    # Enable spy and clear initial setup
    spy.enable()
    spy.clear()
    
    # Update ALL items - change supply
    var updatedItems: seq[TokenListItem] = @[]
    for i in 0..<100:
      updatedItems.add(initTokenListItem(
        "key" & $i,
        "Token " & $i,
        "TK" & $i,
        "#FF0000",
        "img" & $i,
        1,
        "",
        $2000,  # Changed!
        false,
        18,
        0
      ))
    
    model.setItems(updatedItems)
    
    # Verify state
    check model.items.len == 100
    
    # PROOF: With bulk ops, 100 updates = 1 dataChanged call!
    echo "\n=== BULK OPERATION PROOF ==="
    echo "Updated 100 items, dataChanged calls: ", spy.countDataChanged()
    check spy.countDataChanged() == 1  # Only ONE call for 100 updates!
    
    let changes = spy.getDataChanged()
    check changes[0].topLeft == 0
    check changes[0].bottomRight == 99  # All 100 items!
    
    spy.disable()
  
  test "Community tokens preserved in setWalletTokenItems":
    var model = newTokenListModel()
    var spy = newQtModelSpy()
    
    # Setup with community tokens
    let initialItems = @[
      initTokenListItem("key1", "Token A", "TKA", "#FF0000", "img1", 1, "", "1000", false, 18, 0),
      initTokenListItem("key2", "Community Token", "CTK", "#00FF00", "img2", 0, "0x123", "2000", false, 18, 0),
    ]
    model.setItems(initialItems)
    check model.items.len == 2
    
    # Enable spy and clear initial setup
    spy.enable()
    spy.clear()
    
    # Update wallet tokens only (no community tokens)
    let walletItems = @[
      initTokenListItem("key1", "Token A", "TKA", "#FF0000", "img1", 1, "", "1500", false, 18, 0),  # Updated
      initTokenListItem("key3", "Token C", "TKC", "#0000FF", "img3", 1, "", "3000", false, 18, 0),  # New
    ]
    
    model.setWalletTokenItems(walletItems)
    
    # Verify community token is still there
    check model.items.len == 3
    check model.hasItem("TKA", "")
    check model.hasItem("CTK", "0x123")
    check model.hasItem("TKC", "")
    
    # Verify Qt signals - update TKA + insert TKC (CTK preserved)
    check spy.countDataChanged() == 1  # Update TKA
    check spy.countInserts() == 1  # Insert TKC
    
    spy.disable()
  
  test "Consecutive inserts - bulk optimization":
    var model = newTokenListModel()
    var spy = newQtModelSpy()
    spy.enable()
    
    # Start empty
    check model.items.len == 0
    
    # Insert 10 consecutive items
    var items: seq[TokenListItem] = @[]
    for i in 0..<10:
      items.add(initTokenListItem(
        "key" & $i,
        "Token " & $i,
        "TK" & $i,
        "#FF0000",
        "img" & $i,
        1,
        "",
        $1000,
        false,
        18,
        0
      ))
    
    model.setItems(items)
    
    check model.items.len == 10
    
    # Verify Qt signals - BULK insert!
    check spy.countInserts() == 1  # Only 1 call for 10 items!
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 9  # All 10 items in single call!
    
    spy.disable()
  
  test "Consecutive removes - bulk optimization":
    var model = newTokenListModel()
    var spy = newQtModelSpy()
    
    # Setup with 10 items
    var initialItems: seq[TokenListItem] = @[]
    for i in 0..<10:
      initialItems.add(initTokenListItem(
        "key" & $i,
        "Token " & $i,
        "TK" & $i,
        "#FF0000",
        "img" & $i,
        1,
        "",
        $1000,
        false,
        18,
        0
      ))
    model.setItems(initialItems)
    check model.items.len == 10
    
    # Enable spy and clear initial setup
    spy.enable()
    spy.clear()
    
    # Remove items 3,4,5,6,7 (consecutive)
    let updatedItems = @[
      initialItems[0], initialItems[1], initialItems[2],
      initialItems[8], initialItems[9]
    ]
    
    model.setItems(updatedItems)
    
    check model.items.len == 5
    
    # Verify Qt signals - BULK remove!
    check spy.countRemoves() == 1  # Only 1 call for 5 consecutive removes!
    let removes = spy.getRemoves()
    check removes[0].first == 3
    check removes[0].last == 7  # All 5 items in single call!
    
    spy.disable()
  
  test "Multiple role updates - grouped by same roles":
    var model = newTokenListModel()
    var spy = newQtModelSpy()
    
    # Setup initial state
    let initialItems = @[
      initTokenListItem("key1", "Token A", "TKA", "#FF0000", "img1", 1, "", "1000", false, 18, 0),
      initTokenListItem("key2", "Token B", "TKB", "#00FF00", "img2", 1, "", "2000", false, 18, 0),
      initTokenListItem("key3", "Token C", "TKC", "#0000FF", "img3", 1, "", "3000", false, 18, 0),
    ]
    model.setItems(initialItems)
    
    # Enable spy and clear initial setup
    spy.enable()
    spy.clear()
    
    # Update all items - change supply AND decimals (same roles for all)
    let updatedItems = @[
      initTokenListItem("key1", "Token A", "TKA", "#FF0000", "img1", 1, "", "1500", false, 6, 0),   # Supply + Decimals
      initTokenListItem("key2", "Token B", "TKB", "#00FF00", "img2", 1, "", "2500", false, 6, 0),   # Supply + Decimals
      initTokenListItem("key3", "Token C", "TKC", "#0000FF", "img3", 1, "", "3500", false, 6, 0),   # Supply + Decimals
    ]
    
    model.setItems(updatedItems)
    
    check model.items.len == 3
    
    # Verify Qt signals - BULK dataChanged with multiple roles!
    check spy.countDataChanged() == 1  # Only 1 call for all 3 items!
    let changes = spy.getDataChanged()
    check changes[0].topLeft == 0
    check changes[0].bottomRight == 2  # All 3 items!
    check changes[0].roles.len == 2  # Both Supply and Decimals roles
    
    spy.disable()

when isMainModule:
  echo "Running TokenListModel tests..."

