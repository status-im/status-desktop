import NimQml, sequtils, strutils, sugar

import ../../../../../app_service/service/wallet_account/service as wallet_account_service

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
      modelVariant: QVariant
      generatedVariant: QVariant
      importedVariant: QVariant
      watchOnlyVariant: QVariant
      generatedAccountsVariant: QVariant
      tmpAddress: string
      tmpChainID: int  # shouldn't be used anywhere except in prepareCurrencyAmount/getPreparedCurrencyAmount procs
      tmpSymbol: string # shouldn't be used anywhere except in prepareCurrencyAmount/getPreparedCurrencyAmount procs

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

  proc setItems*(self: View, items: seq[Item]) =
    self.model.setItems(items)
    
    var statusDefaultAccountDerivedFrom: string = ""
    var importedSeedIndex: int = 1

    var watchOnly: seq[Item] = @[]
    var imported: seq[Item] = @[]
    var generated: seq[Item] = @[]

    # create a list of imported seeds/default account created from where more accounts can be derived
    var generatedAccounts: seq[GeneratedWalletItem] = @[]

    for item in items:
      #  Default Account
      if item.getWalletType() == "":
        statusDefaultAccountDerivedFrom = item.getDerivedFrom()

        var generatedAccs: Model = newModel()
        generatedAccs.setItems(items.filter(x => cmpIgnoreCase(x.getDerivedFrom(), item.getDerivedFrom()) == 0))
        generatedAccounts.add(initGeneratedWalletItem("Default", "status", generatedAccs, item.getDerivedFrom(),
          item.getKeyUid(), item.getMigratedToKeycard()))
        generated.add(item)

      # Account generated from profile seed phrase
      elif item.getWalletType() == GENERATED and cmpIgnoreCase(item.getDerivedFrom(), statusDefaultAccountDerivedFrom) == 0 :
        generated.add(item)

      # Watch only accounts
      elif item.getWalletType() == WATCH:
        watchOnly.add(item)

      # Accounts imported with Seed phrase
      elif item.getWalletType() == SEED and imported.all(x => cmpIgnoreCase(x.getDerivedfrom(), item.getDerivedFrom()) != 0):
        var generatedAccs1: Model = newModel()
        var filterItems: seq[Item] = items.filter(x => cmpIgnoreCase(x.getDerivedFrom(), item.getDerivedFrom()) == 0)
        generatedAccs1.setItems(filterItems)
        generatedAccounts.add(initGeneratedWalletItem("Seed " & $importedSeedIndex , "seed-phrase", generatedAccs1, item.getDerivedFrom(),
          item.getKeyUid(), item.getMigratedToKeycard()))
        imported.add(item)
        importedSeedIndex += 1

      # Accounts imported with Key OR accounts generated from a seed thats not the profile seed
      else:
        imported.add(item)

    self.watchOnly.setItems(watchOnly)
    self.imported.setItems(imported)
    self.generated.setItems(generated)
    self.generatedAccounts.setItems(generatedAccounts)

  proc deleteAccount*(self: View, keyUid: string, address: string) {.slot.} =
    self.delegate.deleteAccount(keyUid, address)

  proc getAccountNameByAddress*(self: View, address: string): string {.slot.} =
    return self.model.getAccountNameByAddress(address)

  proc getAccountIconColorByAddress*(self: View, address: string): string {.slot.} =
    return self.model.getAccountIconColorByAddress(address)

  proc setAddressForAssets*(self: View, address: string) {.slot.} =
    self.tmpAddress = address

  proc getAccountAssetsByAddress*(self: View): QVariant {.slot.} =
    self.tmpAddress = ""
    return self.model.getAccountAssetsByAddress(self.tmpAddress)

  # Returning a QVariant from a slot with parameters other than "self" won't compile
  #proc getTokenBalanceOnChain*(self: View, chainId: int, tokenSymbol: string): QVariant {.slot.} =
  #  return newQVariant(self.assets.getTokenBalanceOnChain(chainId, tokenSymbol))

  # As a workaround, we do it in two steps: First call prepareTokenBalanceOnChain, then getPreparedTokenBalanceOnChain
  proc prepareTokenBalanceOnChain*(self: View, address: string, chainId: int, tokenSymbol: string) {.slot.} =
    self.tmpAddress = address
    self.tmpChainId = chainId
    self.tmpSymbol = tokenSymbol

  proc getPreparedTokenBalanceOnChain*(self: View): QVariant {.slot.} =
    let currencyAmount = self.model.getTokenBalanceOnChain(self.tmpAddress, self.tmpChainId, self.tmpSymbol)
    self.tmpAddress = ""
    self.tmpChainId = 0
    self.tmpSymbol = "ERROR"
    return newQVariant(currencyAmount)
