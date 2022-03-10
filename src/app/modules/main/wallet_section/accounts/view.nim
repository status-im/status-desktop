import NimQml

import ./model
import ./item
import ./io_interface

const WATCH = "watch"
const GENERATED = "generated"

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      generated: Model
      watchOnly: Model
      imported: Model
      modelVariant: QVariant
      generatedVariant: QVariant
      importedVariant: QVariant
      watchOnlyVariant: QVariant
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

  proc generateNewAccount*(self: View, password: string, accountName: string, color: string, emoji: string): string {.slot.} =
    return self.delegate.generateNewAccount(password, accountName, color, emoji)

  proc addAccountsFromPrivateKey*(self: View, privateKey: string, password: string, accountName: string, color: string, emoji: string): string {.slot.} =
    return self.delegate.addAccountsFromPrivateKey(privateKey, password, accountName, color, emoji)

  proc addAccountsFromSeed*(self: View, seedPhrase: string, password: string, accountName: string, color: string, emoji: string): string {.slot.} =
    return self.delegate.addAccountsFromSeed(seedPhrase, password, accountName, color, emoji)

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
