import NimQml, sequtils, strutils, sugar

import ./model
import ./item
import ./io_interface
import ./generated_wallet_model
import ./generated_wallet_item
import ./derived_address_model
import ./derived_address_item

const WATCH = "watch"
const GENERATED = "generated"
const SEED = "seed"
const KEY = "key"

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      generated: Model
      watchOnly: Model
      imported: Model
      generatedAccounts: GeneratedWalletModel
      derivedAddresses: DerivedAddressModel
      modelVariant: QVariant
      generatedVariant: QVariant
      importedVariant: QVariant
      watchOnlyVariant: QVariant
      generatedAccountsVariant: QVariant
      derivedAddressesVariant: QVariant
      tmpAddress: string

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.imported.delete
    self.importedVariant.delete
    self.generated.delete
    self.generatedVariant.delete
    self.watchOnly.delete
    self.watchOnlyVariant.delete
    self.generatedAccounts.delete
    self.generatedAccountsVariant.delete
    self.derivedAddresses.delete
    self.derivedAddressesVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.imported = newModel()
    result.importedVariant = newQVariant(result.imported)
    result.generated = newModel()
    result.generatedVariant = newQVariant(result.generated)
    result.watchOnly = newModel()
    result.watchOnlyVariant = newQVariant(result.watchOnly)
    result.generatedAccounts = newGeneratedWalletModel()
    result.generatedAccountsVariant = newQVariant(result.generatedAccounts)
    result.derivedAddresses = newDerivedAddressModel()
    result.derivedAddressesVariant = newQVariant(result.derivedAddresses)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc watchOnlyChanged*(self: View) {.signal.}

  proc getWatchOnly(self: View): QVariant {.slot.} =
    return self.watchOnlyVariant

  QtProperty[QVariant] watchOnly:
    read = getWatchOnly
    notify = watchOnlyChanged
  
  proc importedChanged*(self: View) {.signal.}

  proc getImported(self: View): QVariant {.slot.} =
    return self.importedVariant

  QtProperty[QVariant] imported:
    read = getImported
    notify = importedChanged

  proc generatedChanged*(self: View) {.signal.}

  proc getGenereated(self: View): QVariant {.slot.} =
    return self.generatedVariant

  QtProperty[QVariant] generated:
    read = getGenereated
    notify = generatedChanged

  proc generatedAccountsChanged*(self: View) {.signal.}

  proc getGeneratedAccounts(self: View): QVariant {.slot.} =
    return self.generatedAccountsVariant

  QtProperty[QVariant] generatedAccounts:
    read = getGeneratedAccounts
    notify = generatedAccountsChanged

  proc derivedAddressesChanged*(self: View) {.signal.}

  proc getDerivedAddresses(self: View): QVariant {.slot.} =
    return self.derivedAddressesVariant

  QtProperty[QVariant] derivedAddresses:
    read = getDerivedAddresses
    notify = derivedAddressesChanged

  proc setItems*(self: View, items: seq[Item]) =
    self.model.setItems(items)
    
    var watchOnly: seq[Item] = @[]
    var imported: seq[Item] = @[]
    var generated: seq[Item] = @[]

    for item in items:
      if item.getWalletType() == "" or item.getWalletType() == GENERATED:
        generated.add(item)
      elif item.getWalletType() == WATCH:
        watchOnly.add(item)
      else:
        imported.add(item)

    self.watchOnly.setItems(watchOnly)
    self.imported.setItems(imported)
    self.generated.setItems(generated)

    # create a list of imported seeds/default account created from where more accounts can be derived
    var generatedAccounts: seq[GeneratedWalletItem] = @[]
    var importedSeedIndex: int = 1
    for item in items:
      if item.getWalletType() == "":
        var generatedAccs: Model = newModel()
        generatedAccs.setItems(generated.filter(x => cmpIgnoreCase(x.getDerivedFrom(), item.getDerivedFrom()) == 0))
        generatedAccounts.add(initGeneratedWalletItem("Default", "status", generatedAccs, item.getDerivedFrom()))
      elif item.getWalletType() == SEED:
        var generatedAccs1: Model = newModel()
        var filterItems: seq[Item] = generated.filter(x => cmpIgnoreCase(x.getDerivedFrom(), item.getDerivedFrom()) == 0)
        filterItems.insert(item, 0)
        generatedAccs1.setItems(filterItems)
        generatedAccounts.add(initGeneratedWalletItem("Seed " & $importedSeedIndex , "seed-phrase", generatedAccs1, item.getDerivedFrom()))
        importedSeedIndex += 1
    self.generatedAccounts.setItems(generatedAccounts)


  proc generateNewAccount*(self: View, password: string, accountName: string, color: string, emoji: string, path: string, derivedFrom: string): string {.slot.} =
    return self.delegate.generateNewAccount(password, accountName, color, emoji, path, derivedFrom)

  proc addAccountsFromPrivateKey*(self: View, privateKey: string, password: string, accountName: string, color: string, emoji: string): string {.slot.} =
    return self.delegate.addAccountsFromPrivateKey(privateKey, password, accountName, color, emoji)

  proc addAccountsFromSeed*(self: View, seedPhrase: string, password: string, accountName: string, color: string, emoji: string, path: string): string {.slot.} =
    return self.delegate.addAccountsFromSeed(seedPhrase, password, accountName, color, emoji, path)

  proc addWatchOnlyAccount*(self: View, address: string, accountName: string, color: string, emoji: string): string {.slot.} =
    return self.delegate.addWatchOnlyAccount(address, accountName, color, emoji)

  proc deleteAccount*(self: View, address: string) {.slot.} =
    self.delegate.deleteAccount(address)

  proc getAccountNameByAddress*(self: View, address: string): string {.slot.} =
    return self.model.getAccountNameByAddress(address)

  proc getAccountIconColorByAddress*(self: View, address: string): string {.slot.} =
    return self.model.getAccountIconColorByAddress(address)

  proc setAddressForAssets*(self: View, address: string) {.slot.} =
    self.tmpAddress = address

  proc getAccountAssetsByAddress*(self: View): QVariant {.slot.} =
    return self.model.getAccountAssetsByAddress(self.tmpAddress)

  proc getDerivedAddressList*(self: View, password: string, derivedFrom: string, path: string, pageSize: int, pageNumber: int): string {.slot.} =
    var items: seq[DerivedAddressItem] = @[]
    let (result, error) = self.delegate.getDerivedAddressList(password, derivedfrom, path, pageSize, pageNumber)
    for item in result:
      items.add(initDerivedAddressItem(item.address, item.path, item.hasActivity, item.alreadyCreated))
    self.derivedAddresses.setItems(items)
    self.derivedAddressesChanged()
    return error

  proc getDerivedAddressListForMnemonic*(self: View, mnemonic: string, path: string, pageSize: int, pageNumber: int): string {.slot.} =
    var items: seq[DerivedAddressItem] = @[]
    let (result, error) = self.delegate.getDerivedAddressListForMnemonic(mnemonic, path, pageSize, pageNumber)
    for item in result:
      items.add(initDerivedAddressItem(item.address, item.path, item.hasActivity, item.alreadyCreated))
    self.derivedAddresses.setItems(items)
    self.derivedAddressesChanged()
    return error

  proc resetDerivedAddressModel*(self: View) {.slot.} =
    var items: seq[DerivedAddressItem] = @[]
    self.derivedAddresses.setItems(items)
    self.derivedAddressesChanged()

  proc getDerivedAddressAtIndex*(self: View, index: int): string {.slot.} =
    return self.derivedAddresses.getDerivedAddressAtIndex(index)

  proc getDerivedAddressPathAtIndex*(self: View, index: int): string {.slot.} =
    return self.derivedAddresses.getDerivedAddressPathAtIndex(index)

  proc getDerivedAddressHasActivityAtIndex*(self: View, index: int): bool {.slot.} =
    return self.derivedAddresses.getDerivedAddressHasActivityAtIndex(index)

  proc getDerivedAddressAlreadyCreatedAtIndex*(self: View, index: int): bool {.slot.} =
    return self.derivedAddresses.getDerivedAddressAlreadyCreatedAtIndex(index)

  proc getNextSelectableDerivedAddressIndex*(self: View): int {.slot.} =
    return self.derivedAddresses.getNextSelectableDerivedAddressIndex()

