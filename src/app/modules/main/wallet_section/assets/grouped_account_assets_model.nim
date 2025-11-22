import nimqml, tables, sequtils

import ./io_interface, ./balances_model
import app/core/cow_seq  # For CowSeq.len and [] access
import app/modules/shared/model_sync  # For efficient granular updates
import app_service/service/wallet_account/dto/account_token_item  # For GroupedTokenItem

type
  ModelRole {.pure.} = enum
    TokensKey = UserRole + 1,
    Balances

QtObject:
  type
    Model* = ref object of QAbstractListModel
      delegate: io_interface.GroupedAccountAssetsDataSource
      items: CowSeq[GroupedTokenItem]  # Cached CoW - prevents delegate from changing model data
      balancesPerChain: seq[BalancesModel]

  proc delete(self: Model)
  proc setup(self: Model)
  proc newModel*(delegate: io_interface.GroupedAccountAssetsDataSource): Model =
    new(result, delete)
    result.setup
    result.delegate = delegate
    # Don't cache data yet - wait for modelsUpdated() to properly initialize nested models

  proc countChanged(self: Model) {.signal.}
  proc getCount*(self: Model): int {.slot.} =
    return self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.TokensKey.int:"tokensKey",
      ModelRole.Balances.int:"balances",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if index.row < 0 or index.row >= self.rowCount():
      return
      
    if index.row >= self.balancesPerChain.len:
      return

    let enumRole = role.ModelRole
    let item = self.items[index.row]
    case enumRole:
    of ModelRole.TokensKey:
      result = newQVariant(item.tokensKey)
    of ModelRole.Balances:
      result = newQVariant(self.balancesPerChain[index.row])

  proc modelsUpdated*(self: Model) =
    # Get new items from delegate (O(1) copy via CoW!)
    let newItemsCow = self.delegate.getGroupedAccountsAssetsList()
    
    # Convert both old and new to seq for diffing
    var oldItems = self.items.asSeq()  # Current cached CoW
    let newItems = newItemsCow.asSeq()  # New CoW from delegate
    
    # Use setItemsWithSync for granular updates (diffs the seqs)
    setItemsWithSync(
      self,  # Model is first parameter!
      oldItems,  # Pass seq (will be mutated by setItemsWithSync)
      newItems,
      getId = proc(item: GroupedTokenItem): string = item.tokensKey,
      updateItem = proc(existing: GroupedTokenItem, updated: GroupedTokenItem) =
        # Find the index for this item to update its nested model
        for idx in 0..<self.items.len:
          if self.items[idx].tokensKey == existing.tokensKey:
            # Ensure nested balances model exists
            while self.balancesPerChain.len <= idx:
              self.balancesPerChain.add(newBalancesModel(self.delegate, self.balancesPerChain.len))
            # Update nested balances model: diff old vs new balances
            self.balancesPerChain[idx].update(existing.balancesPerAccount, updated.balancesPerAccount)
            break,
      countChanged = proc() = self.countChanged(),
      useBulkOps = true,
      afterItemSync = proc(oldItem: GroupedTokenItem, newItem: var GroupedTokenItem, idx: int) =
        # Ensure nested balances model exists for newly inserted items
        # We need one model per parent item, indexed to match parent's index
        while self.balancesPerChain.len <= idx:
          # Create models up to idx, each with its own index
          let newModelIdx = self.balancesPerChain.len
          self.balancesPerChain.add(newBalancesModel(self.delegate, newModelIdx))
        
        # Now update the nested model at idx (which should exist after the while loop)
        self.balancesPerChain[idx].update(oldItem.balancesPerAccount, newItem.balancesPerAccount)
    )
    
    # Cache the new CowSeq (O(1) - just increment refcount!)
    self.items = newItemsCow

  proc delete(self: Model) =
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup
    self.items = toCowSeq(newSeq[GroupedTokenItem](0))  # Initialize with empty CowSeq
    self.balancesPerChain = @[]

