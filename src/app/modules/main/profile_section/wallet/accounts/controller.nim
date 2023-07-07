import io_interface
import ../../../../../../app_service/service/wallet_account/service as wallet_account_service

import ../../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    walletAccountService: wallet_account_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  walletAccountService: wallet_account_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.walletAccountService = walletAccountService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getWalletAccounts()

proc updateAccount*(self: Controller, address: string, accountName: string, colorId: string, emoji: string) =
  discard self.walletAccountService.updateWalletAccount(address, accountName, colorId, emoji)

proc updateAccountPosition*(self: Controller, address: string, position: int) =
  self.walletAccountService.updateWalletAccountPosition(address, position)

proc deleteAccount*(self: Controller, address: string) =
  self.walletAccountService.deleteAccount(address)

proc getKeycardsWithSameKeyUid*(self: Controller, keyUid: string): seq[KeycardDto] =
  return self.walletAccountService.getKeycardsWithSameKeyUid(keyUid)

proc isKeycardAccount*(self: Controller, account: WalletAccountDto): bool =
  return self.walletAccountService.isKeycardAccount(account)

proc getWalletAccount*(self: Controller, address: string): WalletAccountDto =
  return self.walletAccountService.getAccountByAddress(address)

proc getKeypairs*(self: Controller): seq[KeypairDto] =
  return self.walletAccountService.getKeypairs()

proc toggleIncludeWatchOnlyAccount*(self: Controller) =
  self.walletAccountService.toggleIncludeWatchOnlyAccount()

proc isIncludeWatchOnlyAccount*(self: Controller): bool =
  return self.walletAccountService.isIncludeWatchOnlyAccount()
