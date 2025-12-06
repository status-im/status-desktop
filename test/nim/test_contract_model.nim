import unittest
import ../../src/app/modules/shared_models/contract_model
import ../../src/app/modules/shared_models/contract_item
import ../../src/app/modules/shared/qt_model_spy

# Test suite for ContractModel with model_sync optimization

proc createTestContract(chainId: int, addressSuffix: int): Item =
  initItem(chainId, "0xcontract" & $addressSuffix)

suite "ContractModel - Granular Updates":
  
  test "Insert contracts - bulk insert":
    var model = newModel()
    var spy = newQtModelSpy()
    spy.enable()
    
    var items: seq[Item] = @[]
    for i in 1..5:
      items.add(createTestContract(i, i))
    
    model.setItems(items)
    
    # Verify Qt signals - BULK insert!
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 4  # All 5 contracts!
    
    spy.disable()
  
  test "Mixed operations - add and remove contracts":
    var model = newModel()
    var spy = newQtModelSpy()
    
    # Setup initial contracts on chains 1,2,3
    var initialItems: seq[Item] = @[]
    initialItems.add(createTestContract(1, 1))
    initialItems.add(createTestContract(2, 1))
    initialItems.add(createTestContract(3, 1))
    
    model.setItems(initialItems)
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Keep chain 2, remove chains 1,3, add chain 4
    var updatedItems: seq[Item] = @[]
    updatedItems.add(createTestContract(2, 1))  # Keep
    updatedItems.add(createTestContract(4, 1))  # Add
    
    model.setItems(updatedItems)
    
    # Verify Qt signals - 2 removes, 1 insert
    check spy.countRemoves() == 2
    check spy.countInserts() == 1
    
    spy.disable()
  
  test "Remove contracts":
    var model = newModel()
    var spy = newQtModelSpy()
    
    # Setup 10 contracts
    var initialItems: seq[Item] = @[]
    for i in 1..10:
      initialItems.add(createTestContract(1, i))
    
    model.setItems(initialItems)
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Keep only odd contracts
    var updatedItems: seq[Item] = @[]
    for i in [1, 3, 5, 7, 9]:
      updatedItems.add(initialItems[i-1])
    
    model.setItems(updatedItems)
    
    # Verify Qt signals - 5 removes
    check spy.countRemoves() == 5
    
    spy.disable()
  
  test "Large contract list - 100 contracts bulk insert":
    var model = newModel()
    var spy = newQtModelSpy()
    spy.enable()
    
    # Create 100 contracts - bulk insert!
    var items: seq[Item] = @[]
    for i in 1..100:
      items.add(createTestContract(1, i))
    
    model.setItems(items)
    
    # PROOF: 100 contracts = 1 insert call!
    echo "\n=== CONTRACT MODEL BULK PROOF ==="
    echo "Inserted 100 contracts, insert calls: ", spy.countInserts()
    check spy.countInserts() == 1
    
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 99
    
    spy.disable()

when isMainModule:
  echo "Running ContractModel tests..."

