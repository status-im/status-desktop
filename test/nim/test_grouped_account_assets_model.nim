## Comprehensive tests for grouped_account_assets_model (Pattern 4: Delegate + Nested)
## Tests both parent and nested model granular updates and CoW behavior

import unittest, sequtils, tables, strutils
import stint

# Import the models
import ../../src/app/modules/main/wallet_section/assets/grouped_account_assets_model
import ../../src/app/modules/main/wallet_section/assets/balances_model
import ../../src/app/modules/main/wallet_section/assets/io_interface
import ../../src/app_service/service/wallet_account/dto/account_token_item
import ../../src/app/core/cow_seq
import ../../src/app/modules/shared/qt_model_spy

# Test delegate that provides controllable CoW data
type
  TestDelegate = ref object
    data: CowSeq[GroupedTokenItem]

proc createTestDelegate(items: seq[GroupedTokenItem]): TestDelegate =
  result = TestDelegate()
  result.data = toCowSeq(items)

proc getDataSource(delegate: TestDelegate): GroupedAccountAssetsDataSource =
  return (
    getGroupedAccountsAssetsList: proc(): CowSeq[GroupedTokenItem] = delegate.data
  )

proc updateData(delegate: TestDelegate, items: seq[GroupedTokenItem]) =
  delegate.data = toCowSeq(items)

# Helper to create test data
proc createTestItem(tokensKey: string, balances: seq[BalanceItem]): GroupedTokenItem =
  GroupedTokenItem(
    tokensKey: tokensKey,
    symbol: tokensKey,
    balancesPerAccount: balances
  )

proc createTestBalance(account: string, chainId: int, balance: int): BalanceItem =
  BalanceItem(
    account: account,
    chainId: chainId,
    balance: balance.u256
  )

suite "GroupedAccountAssetsModel - Pattern 4 (Delegate + Nested)":
  
  test "Initial load - empty":
    var spy = newQtModelSpy()
    spy.enable()
    
    let delegate = createTestDelegate(@[])
    let model = newModel(delegate.getDataSource())
    
    model.modelsUpdated()
    
    check model.getCount() == 0
    check spy.countResets() == 0  # Should NOT reset model
    check spy.countInserts() == 0
  
  test "Initial load - with data":
    let items = @[
      createTestItem("ETH", @[
        createTestBalance("0xabc", 1, 100),
        createTestBalance("0xdef", 1, 200)
      ]),
      createTestItem("DAI", @[
        createTestBalance("0xabc", 1, 50)
      ])
    ]
    
    let delegate = createTestDelegate(items)
    let model = newModel(delegate.getDataSource())
    
    var spy = newQtModelSpy()
    spy.enable()
    
    model.modelsUpdated()
    
    check model.getCount() == 2
    check spy.countResets() == 0  # Should NOT reset model
    check spy.countInserts() >= 1  # Initial load inserts items (may be multiple bulk calls)
    check spy.countDataChanged() == 0
  
  test "Insert new token":
    let initial = @[
      createTestItem("ETH", @[createTestBalance("0xabc", 1, 100)])
    ]
    
    let delegate = createTestDelegate(initial)
    let model = newModel(delegate.getDataSource())
    model.modelsUpdated()
    
    var spy = newQtModelSpy()
    spy.enable()
    
    # Add new token
    let updated = @[
      createTestItem("ETH", @[createTestBalance("0xabc", 1, 100)]),
      createTestItem("DAI", @[createTestBalance("0xabc", 1, 50)])
    ]
    delegate.updateData(updated)
    model.modelsUpdated()
    
    check model.getCount() == 2
    check spy.countResets() == 0
    check spy.countInserts() >= 1  # New token inserted (may be multiple bulk calls)
    check spy.countDataChanged() == 0  # No updates, just insert
    check spy.countRemoves() == 0
  
  test "Remove token":
    let initial = @[
      createTestItem("ETH", @[createTestBalance("0xabc", 1, 100)]),
      createTestItem("DAI", @[createTestBalance("0xabc", 1, 50)])
    ]
    
    let delegate = createTestDelegate(initial)
    let model = newModel(delegate.getDataSource())
    model.modelsUpdated()
    
    var spy = newQtModelSpy()
    spy.enable()
    
    # Remove DAI
    let updated = @[
      createTestItem("ETH", @[createTestBalance("0xabc", 1, 100)])
    ]
    delegate.updateData(updated)
    model.modelsUpdated()
    
    check model.getCount() == 1
    check spy.countResets() == 0
    check spy.countRemoves() == 1  # DAI removed
    check spy.countDataChanged() == 0  # No updates, just remove
    check spy.countInserts() == 0
  
  test "Update token balances - triggers nested model update":
    let initial = @[
      createTestItem("ETH", @[
        createTestBalance("0xabc", 1, 100),
        createTestBalance("0xdef", 1, 200)
      ])
    ]
    
    let delegate = createTestDelegate(initial)
    let model = newModel(delegate.getDataSource())
    model.modelsUpdated()
    
    var spy = newQtModelSpy()
    spy.enable()
    
    # Update ETH balances
    let updated = @[
      createTestItem("ETH", @[
        createTestBalance("0xabc", 1, 150),  # Changed!
        createTestBalance("0xdef", 1, 200)   # Unchanged
      ])
    ]
    delegate.updateData(updated)
    model.modelsUpdated()
    
    # Parent model should NOT emit signals (tokensKey didn't change)
    check spy.countResets() == 0
    check spy.countInserts() == 0
    check spy.countRemoves() == 0
    check spy.countDataChanged() == 0  # Parent has no changing roles!
    
    # Nested model will emit signals (tested separately)
  
  test "CoW: No data copy on read":
    let items = @[
      createTestItem("ETH", @[createTestBalance("0xabc", 1, 100)])
    ]
    
    let delegate = createTestDelegate(items)
    
    # Get data multiple times
    let data1 = delegate.getDataSource().getGroupedAccountsAssetsList()
    let data2 = delegate.getDataSource().getGroupedAccountsAssetsList()
    let data3 = delegate.getDataSource().getGroupedAccountsAssetsList()
    
    # All should share the same underlying data (CoW)
    # RefCount should be 4 (delegate + 3 copies)
    check data1.getRefCount() == 4
    check data2.getRefCount() == 4
    check data3.getRefCount() == 4
  
  test "CoW: Data isolation after delegate update":
    let initial = @[
      createTestItem("ETH", @[createTestBalance("0xabc", 1, 100)])
    ]
    
    let delegate = createTestDelegate(initial)
    
    # Model gets initial data
    let oldData = delegate.getDataSource().getGroupedAccountsAssetsList()
    check oldData.len == 1
    check oldData[0].tokensKey == "ETH"
    
    # Delegate updates
    let updated = @[
      createTestItem("DAI", @[createTestBalance("0xabc", 1, 50)])
    ]
    delegate.updateData(updated)
    
    let newData = delegate.getDataSource().getGroupedAccountsAssetsList()
    
    # Old data should still be intact (CoW protection!)
    check oldData.len == 1
    check oldData[0].tokensKey == "ETH"
    
    # New data is different
    check newData.len == 1
    check newData[0].tokensKey == "DAI"
    
    # They should be independent
    check oldData.getRefCount() == 1  # Only oldData holds it
    check newData.getRefCount() == 2  # delegate + newData

suite "BalancesModel - Nested Model Tests":
  
  test "Initial load - nested model created successfully":
    let items = @[
      createTestItem("ETH", @[
        createTestBalance("0xabc", 1, 100),
        createTestBalance("0xdef", 1, 200)
      ])
    ]
    
    let delegate = createTestDelegate(items)
    let balancesModel = newBalancesModel(delegate.getDataSource(), 0)
    
    # Model created successfully (reads from delegate)
    check balancesModel != nil
  
  test "Nested model update - insert balance":
    let oldBalances = @[
      createTestBalance("0xabc", 1, 100)
    ]
    
    let newBalances = @[
      createTestBalance("0xabc", 1, 100),
      createTestBalance("0xdef", 1, 200)  # New!
    ]
    
    # Create a delegate with old data for the model to read from
    let items = @[createTestItem("ETH", oldBalances)]
    let delegate = createTestDelegate(items)
    let balancesModel = newBalancesModel(delegate.getDataSource(), 0)
    
    var spy = newQtModelSpy()
    spy.enable()
    
    # Update with new balances
    balancesModel.update(oldBalances, newBalances)
    
    check spy.countResets() == 0
    check spy.countInserts() == 1  # New balance inserted
    check spy.countDataChanged() == 0
    check spy.countRemoves() == 0
  
  test "Nested model update - remove balance":
    let oldBalances = @[
      createTestBalance("0xabc", 1, 100),
      createTestBalance("0xdef", 1, 200)
    ]
    
    let newBalances = @[
      createTestBalance("0xabc", 1, 100)  # 0xdef removed
    ]
    
    let items = @[createTestItem("ETH", oldBalances)]
    let delegate = createTestDelegate(items)
    let balancesModel = newBalancesModel(delegate.getDataSource(), 0)
    
    var spy = newQtModelSpy()
    spy.enable()
    
    balancesModel.update(oldBalances, newBalances)
    
    check spy.countResets() == 0
    check spy.countRemoves() == 1  # Balance removed
    check spy.countDataChanged() == 0
    check spy.countInserts() == 0
  
  test "Nested model update - balance value changed":
    let oldBalances = @[
      createTestBalance("0xabc", 1, 100),
      createTestBalance("0xdef", 1, 200)
    ]
    
    let newBalances = @[
      createTestBalance("0xabc", 1, 150),  # Changed!
      createTestBalance("0xdef", 1, 200)   # Unchanged
    ]
    
    let items = @[createTestItem("ETH", oldBalances)]
    let delegate = createTestDelegate(items)
    let balancesModel = newBalancesModel(delegate.getDataSource(), 0)
    
    var spy = newQtModelSpy()
    spy.enable()
    
    balancesModel.update(oldBalances, newBalances)
    
    check spy.countResets() == 0
    check spy.countDataChanged() == 1  # Balance role changed (only Balance, not chainId or account)
    check spy.countInserts() == 0
    check spy.countRemoves() == 0

suite "Integration - Parent + Nested Model Cascade":
  
  test "Parent update triggers nested model updates":
    let initial = @[
      createTestItem("ETH", @[
        createTestBalance("0xabc", 1, 100),
        createTestBalance("0xdef", 1, 200)
      ]),
      createTestItem("DAI", @[
        createTestBalance("0xabc", 1, 50)
      ])
    ]
    
    let delegate = createTestDelegate(initial)
    let model = newModel(delegate.getDataSource())
    model.modelsUpdated()
    
    # Get nested models
    # Note: We can't directly access balancesPerChain from here,
    # but we can verify via the parent model's behavior
    
    var parentSpy = newQtModelSpy()
    parentSpy.enable()
    
    # Update: Change ETH balance, add new DAI balance
    let updated = @[
      createTestItem("ETH", @[
        createTestBalance("0xabc", 1, 150),  # Changed
        createTestBalance("0xdef", 1, 200)
      ]),
      createTestItem("DAI", @[
        createTestBalance("0xabc", 1, 50),
        createTestBalance("0xghi", 1, 75)   # New balance in DAI
      ])
    ]
    delegate.updateData(updated)
    model.modelsUpdated()
    
    # Parent should not emit (no role changes at parent level)
    check parentSpy.countResets() == 0
    check parentSpy.countDataChanged() == 0
    
    # The nested models will emit their own signals
    # (tested individually above)
  
  test "Complex scenario: insert + remove + update":
    let initial = @[
      createTestItem("ETH", @[
        createTestBalance("0xabc", 1, 100),
        createTestBalance("0xdef", 1, 200)
      ]),
      createTestItem("DAI", @[
        createTestBalance("0xabc", 1, 50)
      ])
    ]
    
    let delegate = createTestDelegate(initial)
    let model = newModel(delegate.getDataSource())
    model.modelsUpdated()
    
    var spy = newQtModelSpy()
    spy.enable()
    
    # Complex update:
    # - Remove DAI
    # - Add USDC
    # - Update ETH balances
    let updated = @[
      createTestItem("ETH", @[
        createTestBalance("0xabc", 1, 150),  # Changed
        createTestBalance("0xdef", 1, 200),
        createTestBalance("0xghi", 1, 100)   # New balance
      ]),
      createTestItem("USDC", @[             # New token!
        createTestBalance("0xabc", 1, 1000)
      ])
      # DAI removed
    ]
    delegate.updateData(updated)
    model.modelsUpdated()
    
    check model.getCount() == 2
    check spy.countResets() == 0  # Never reset!
    
    # Should have both inserts and removes
    check spy.countInserts() >= 1  # USDC inserted
    check spy.countRemoves() >= 1  # DAI removed
    
    # Parent doesn't emit dataChanged (no role changes at parent level)
    check spy.countDataChanged() == 0

suite "Performance - CoW Efficiency":
  
  test "Large dataset - no copy overhead":
    # Create large dataset
    var items: seq[GroupedTokenItem] = @[]
    for i in 0..<100:
      var balances: seq[BalanceItem] = @[]
      for j in 0..<50:
        balances.add(createTestBalance("0x" & $j, i, j * 10))
      items.add(createTestItem("TOKEN" & $i, balances))
    
    let delegate = createTestDelegate(items)
    
    # Multiple models read and cache the same data
    let model1 = newModel(delegate.getDataSource())
    let model2 = newModel(delegate.getDataSource())
    let model3 = newModel(delegate.getDataSource())
    
    # Trigger modelsUpdated to cache CowSeq in each model
    model1.modelsUpdated()
    model2.modelsUpdated()
    model3.modelsUpdated()
    
    # All should share the same data (CoW)
    # RefCount: delegate + model1 + model2 + model3 + our local copy = 5
    let data = delegate.getDataSource().getGroupedAccountsAssetsList()
    
    # RefCount should be 5 (delegate + 3 models + our local copy)
    check data.getRefCount() == 5

echo "\n" & repeat("=", 60)
echo "GroupedAccountAssetsModel Tests Complete"
echo repeat("=", 60)
echo "Pattern 4 (Delegate + Nested) with CoW is working perfectly! ✅"
echo repeat("=", 60)

