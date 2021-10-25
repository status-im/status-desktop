import NimQml

import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      name: string
      address: string
      path: string
      color: string
      publicKey: string
      walletType: string
      isWallet: bool
      isChat: bool
      currencyBalance: float64
      
  proc setup(self: View) = 
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.setup()

  proc setData*(self: View, dto: wallet_account_service.WalletAccountDto) =
    self.name = dto.name
    self.address = dto.address
    self.path = dto.path
    self.color = dto.color
    self.publicKey = dto.publicKey
    self.walletType = dto.walletType
    self.isChat = dto.isChat
    self.currencyBalance = dto.getCurrencyBalance()

  proc getName(self: View): QVariant {.slot.} =
    return newQVariant(self.name)

  QtProperty[QVariant] name:
    read = getName

  proc getAddress(self: View): QVariant {.slot.} =
    return newQVariant(self.address)

  QtProperty[QVariant] address:
    read = getAddress

  proc getPath(self: View): QVariant {.slot.} =
    return newQVariant(self.path)

  QtProperty[QVariant] path:
    read = getPath

  proc getColor(self: View): QVariant {.slot.} =
    return newQVariant(self.color)

  QtProperty[QVariant] color:
    read = getColor

  proc getPublicKey(self: View): QVariant {.slot.} =
    return newQVariant(self.publicKey)

  QtProperty[QVariant] publicKey:
    read = getPublicKey

  proc getWalletType(self: View): QVariant {.slot.} =
    return newQVariant(self.walletType)

  QtProperty[QVariant] walletType:
    read = getWalletType

  proc getIsWallet(self: View): QVariant {.slot.} =
    return newQVariant(self.isWallet)

  QtProperty[QVariant] isWallet:
    read = getIsWallet

  proc getIsChat(self: View): QVariant {.slot.} =
    return newQVariant(self.isChat)

  QtProperty[QVariant] isChat:
    read = getIsChat

  proc getCurrencyBalance(self: View): QVariant {.slot.} =
    return newQVariant(self.currencyBalance)

  QtProperty[QVariant] currencyBalance:
    read = getCurrencyBalance

  proc update(self: View, address: string, accountName: string, color: string) {.slot.} =
    self.delegate.update(address, accountName, color)