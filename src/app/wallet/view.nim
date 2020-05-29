import NimQml, Tables
import ../../status/wallet
import ../../status/status
import views/asset_list

QtObject:
  type
    WalletView* = ref object of QAbstractListModel
      assets*: AssetsList
      defaultAccount: string
      status: Status

  proc delete(self: WalletView) =
    self.QAbstractListModel.delete

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc newWalletView*(status: Status): WalletView =
    new(result, delete)
    result.status = status
    result.assets = newAssetsList()
    result.setup

  proc addAssetToList*(self: WalletView, asset: Asset) =
    self.assets.addAssetToList(asset)

  proc getAssetsList(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.assets)

  QtProperty[QVariant] assets:
    read = getAssetsList

  proc onSendTransaction*(self: WalletView, from_value: string, to: string, value: string, password: string): string {.slot.} =
    result = self.status.wallet.sendTransaction(from_value, to, value, password)

  proc setDefaultAccount*(self: WalletView, account: string) =
    self.defaultAccount = account

  proc getDefaultAccount*(self: WalletView): string {.slot.} =
    return self.defaultAccount
