import unittest
import ../../src/app/modules/shared_models/keypair_model
import ../../src/app/modules/shared_models/keypair_item
import ../../src/app/modules/shared/qt_model_spy

# Test suite for KeyPairModel with model_sync optimization

proc createTestKeyPair(i: int): KeyPairItem =
  newKeyPairItem(
    keyUid = "keypair" & $i,
    pubKey = "0xpubkey" & $i,
    locked = false,
    name = "KeyPair" & $i,
    derivedFrom = "",
    lastUsedDerivationIndex = 0
  )

suite "KeyPairModel - Granular Updates":
  
  test "Insert keypairs - bulk insert":
    var model = newKeyPairModel()
    var spy = newQtModelSpy()
    spy.enable()
    
    var items: seq[KeyPairItem] = @[]
    for i in 1..5:
      items.add(createTestKeyPair(i))
    
    model.setItems(items)
    
    # Verify Qt signals - BULK insert!
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 4  # All 5 keypairs!
    
    spy.disable()
  
  test "Update keypairs - Pattern 5 uses setters (no dataChanged)":
    var model = newKeyPairModel()
    var spy = newQtModelSpy()
    
    # Setup initial keypairs
    var initialItems: seq[KeyPairItem] = @[]
    for i in 1..10:
      initialItems.add(createTestKeyPair(i))
    
    model.setItems(initialItems)
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Update all - change names
    var updatedItems: seq[KeyPairItem] = @[]
    for i in 1..10:
      var item = createTestKeyPair(i)
      item.setName("Updated" & $i)  # Name changed!
      updatedItems.add(item)
    
    model.setItems(updatedItems)
    
    # Pattern 5: NO dataChanged calls! Setters handle property signals instead
    # This is the optimization - QML only re-evaluates keyPair.name bindings,
    # not all keyPair.* properties
    check spy.countDataChanged() == 0  # ← Pattern 5: No dataChanged!
    
    # Verify structural changes still tracked
    check spy.countInserts() == 0
    check spy.countRemoves() == 0
    
    spy.disable()
  
  test "Large keypair list - 50 keypairs bulk insert":
    var model = newKeyPairModel()
    var spy = newQtModelSpy()
    spy.enable()
    
    # Create 50 keypairs - bulk insert!
    var items: seq[KeyPairItem] = @[]
    for i in 1..50:
      items.add(createTestKeyPair(i))
    
    model.setItems(items)
    
    # PROOF: 50 keypairs = 1 insert call!
    echo "\n=== KEYPAIR MODEL BULK INSERT PROOF ==="
    echo "Inserted 50 keypairs, insert calls: ", spy.countInserts()
    check spy.countInserts() == 1
    
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 49
    
    spy.disable()
  
  test "Large keypair list - Pattern 5 proof (50 updates)":
    var model = newKeyPairModel()
    var spy = newQtModelSpy()
    
    # Setup 50 keypairs
    var initialItems: seq[KeyPairItem] = @[]
    for i in 1..50:
      initialItems.add(createTestKeyPair(i))
    
    model.setItems(initialItems)
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Update all - toggle locked status
    var updatedItems: seq[KeyPairItem] = @[]
    for i in 1..50:
      var item = createTestKeyPair(i)
      item.setLocked(true)  # Locked changed!
      updatedItems.add(item)
    
    model.setItems(updatedItems)
    
    # PROOF: Pattern 5 optimization working!
    echo "\n=== KEYPAIR MODEL PATTERN 5 PROOF ==="
    echo "Updated 50 keypairs, dataChanged calls: ", spy.countDataChanged()
    check spy.countDataChanged() == 0  # ← No dataChanged with Pattern 5!
    
    spy.disable()

when isMainModule:
  echo "Running KeyPairModel tests..."

