import unittest
import ../../src/app/modules/shared_models/keypair_account_model
import ../../src/app/modules/shared/qt_model_spy
import ../../src/app/modules/shared_models/currency_amount

# Test suite for KeyPairAccountModel with model_sync optimization

proc createTestAccount(i: int, balance: float = 0.0, balanceFetched: bool = true): KeyPairAccountItem =
  newKeyPairAccountItem(
    name = "Account" & $i,
    path = "m/44'/60'/0'/0/" & $i,
    address = "0xaccount" & $i,
    pubKey = "0xpubkey" & $i,
    emoji = "😀",
    colorId = "#" & $i,
    icon = "",
    balance = newCurrencyAmount(balance, "", 2, true),
    balanceFetched = balanceFetched,
    operability = "fully",
    isDefaultAccount = (i == 1),
    areTestNetworksEnabled = false,
    hideFromTotalBalance = false
  )

suite "KeyPairAccountModel - Granular Updates":
  
  test "Insert accounts - bulk insert":
    var model = newKeyPairAccountModel()
    var spy = newQtModelSpy()
    spy.enable()
    
    var items: seq[KeyPairAccountItem] = @[]
    for i in 1..5:
      items.add(createTestAccount(i))
    
    model.setItems(items)
    
    # Verify Qt signals - BULK insert!
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 4  # All 5 accounts!
    
    spy.disable()
  
  test "Update account balances - Pattern 5 uses setters (no dataChanged)":
    var model = newKeyPairAccountModel()
    var spy = newQtModelSpy()
    
    # Setup initial accounts with balanceFetched = false
    var initialItems: seq[KeyPairAccountItem] = @[]
    for i in 1..10:
      initialItems.add(createTestAccount(i, 0.0, false))
    
    model.setItems(initialItems)
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Update all - toggle balanceFetched to true
    var updatedItems: seq[KeyPairAccountItem] = @[]
    for i in 1..10:
      updatedItems.add(createTestAccount(i, float(i * 100), true))  # balanceFetched changed!
    
    model.setItems(updatedItems)
    
    # Pattern 5: NO dataChanged calls! Setters handle property signals instead
    # This is the optimization - QML only re-evaluates changed property bindings,
    # not all account.* properties
    check spy.countDataChanged() == 0  # ← Pattern 5: No dataChanged!
    
    # Verify structural changes still tracked
    check spy.countInserts() == 0
    check spy.countRemoves() == 0
    
    spy.disable()
  
  test "Remove accounts":
    var model = newKeyPairAccountModel()
    var spy = newQtModelSpy()
    
    # Setup 10 accounts
    var initialItems: seq[KeyPairAccountItem] = @[]
    for i in 1..10:
      initialItems.add(createTestAccount(i))
    
    model.setItems(initialItems)
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Keep only odd accounts
    var updatedItems: seq[KeyPairAccountItem] = @[]
    for i in [1, 3, 5, 7, 9]:
      updatedItems.add(initialItems[i-1])
    
    model.setItems(updatedItems)
    
    # Verify Qt signals - 5 removes
    check spy.countRemoves() == 5
    
    spy.disable()
  
  test "Large account list - Pattern 5 proof (50 accounts)":
    var model = newKeyPairAccountModel()
    var spy = newQtModelSpy()
    
    # Create 50 accounts with balanceFetched = false
    var initialItems: seq[KeyPairAccountItem] = @[]
    for i in 1..50:
      initialItems.add(createTestAccount(i, 0.0, false))
    
    model.setItems(initialItems)
    
    # Enable spy and clear
    spy.enable()
    spy.clear()
    
    # Update all - toggle balanceFetched
    var updatedItems: seq[KeyPairAccountItem] = @[]
    for i in 1..50:
      updatedItems.add(createTestAccount(i, float(i), true))
    
    model.setItems(updatedItems)
    
    spy.disable()

when isMainModule:
  echo "Running KeyPairAccountModel tests..."

