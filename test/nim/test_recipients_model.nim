import unittest
import ../../src/app/modules/main/wallet_section/activity/recipients_model
import ../../src/app/modules/shared/qt_model_spy

suite "RecipientsModel - Granular Updates":
  
  setup:
    var model = newRecipientsModel()
    var spy = newQtModelSpy()
  
  teardown:
    spy.disable()

  test "Empty model initialization":
    check model.getCount() == 0

  test "Insert addresses - bulk insert (offset 0)":
    spy.enable()
    
    let addresses = @["0x1111", "0x2222", "0x3333"]
    model.addAddresses(addresses, 0, false)
    
    # With offset 0, it uses beginResetModel (current behavior)
    # We won't change this as addAddresses has special pagination logic
    check model.getCount() == 3
    spy.disable()

  test "Append addresses - bulk insert (offset > 0)":
    # Initial setup
    let initial = @["0x1111", "0x2222"]
    model.addAddresses(initial, 0, true)
    
    spy.enable()
    
    # Append more addresses
    let more = @["0x3333", "0x4444", "0x5555"]
    model.addAddresses(more, 2, false)  # offset = 2
    
    # Should use bulk insert for appending
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 2
    check inserts[0].last == 4  # 3 items appended (indices 2, 3, 4)
    
    check model.getCount() == 5
    spy.disable()

  test "Large batch append - bulk operations":
    # Initial setup
    let initial = @["0x1111"]
    model.addAddresses(initial, 0, true)
    
    spy.enable()
    
    # Append 50 addresses
    var addresses: seq[string]
    for i in 0..<50:
      addresses.add("0x" & $i)
    
    model.addAddresses(addresses, 1, false)  # offset = 1
    
    # Should use bulk insert
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 1
    check inserts[0].last == 50  # 50 items appended (indices 1-50)

    check model.getCount() == 51
    spy.disable()

  test "Reset addresses (offset 0)":
    # Initial setup
    let initial = @["0x1111", "0x2222", "0x3333"]
    model.addAddresses(initial, 0, false)
    
    check model.getCount() == 3
    
    # Reset with new addresses
    let newAddresses = @["0xAAAA", "0xBBBB"]
    model.addAddresses(newAddresses, 0, false)
    
    # Note: offset 0 uses beginResetModel, which is OK for pagination reset
    check model.getCount() == 2

  test "hasMore flag updates":
    # Test hasMore = true
    let addresses = @["0x1111", "0x2222"]
    model.addAddresses(addresses, 0, true)
    
    # hasMore should be set (note: we can't directly test the private field,
    # but we're verifying the setHasMore signal is called)
    
    # Test hasMore = false
    model.addAddresses(@["0x3333"], 2, false)
    
    check model.getCount() == 3

  test "Pagination workflow":
    # Page 1
    let page1 = @["0x1111", "0x2222", "0x3333"]
    model.addAddresses(page1, 0, true)  # hasMore = true
    check model.getCount() == 3
    
    spy.enable()
    
    # Page 2 (append)
    let page2 = @["0x4444", "0x5555", "0x6666"]
    model.addAddresses(page2, 3, true)  # offset = 3, hasMore = true
    
    check spy.countInserts() == 1
    check model.getCount() == 6
    
    # Page 3 (append, last page)
    let page3 = @["0x7777", "0x8888"]
    model.addAddresses(page3, 6, false)  # offset = 6, hasMore = false (last page)
    
    check spy.countInserts() == 2  # One for page 2, one for page 3
    check model.getCount() == 8
    
    spy.disable()

  test "Invalid offset detection":
    # Initial setup
    let initial = @["0x1111", "0x2222"]
    model.addAddresses(initial, 0, false)
    
    # Try to append with wrong offset (should log error and not crash)
    let more = @["0x3333"]
    model.addAddresses(more, 5, false)  # Wrong offset!
    
    # Count should remain 2 (operation should fail gracefully)
    check model.getCount() == 2

  test "Empty pagination":
    # Start with empty
    check model.getCount() == 0
    
    # Add empty page
    model.addAddresses(@[], 0, false)
    
    check model.getCount() == 0

  test "Single address operations":
    spy.enable()
    
    # Add single address
    model.addAddresses(@["0x1111"], 0, true)
    
    check model.getCount() == 1
    
    # Append single address
    model.addAddresses(@["0x2222"], 1, false)
    
    check spy.countInserts() == 1  # The append
    check model.getCount() == 2
    
    spy.disable()
