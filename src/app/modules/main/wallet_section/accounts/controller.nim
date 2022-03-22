import ./controller_interface
import io_interface
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    walletAccountService: wallet_account_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  walletAccountService: wallet_account_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.walletAccountService = walletAccountService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  discard

method getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getWalletAccounts()

method generateNewAccount*(self: Controller, password: string, accountName: string, color: string, emoji: string): string =
  return self.walletAccountService.generateNewAccount(password, accountName, color, emoji)

method addAccountsFromPrivateKey*(self: Controller, privateKey: string, password: string, accountName: string, color: string, emoji: string): string =
  return self.walletAccountService.addAccountsFromPrivateKey(privateKey, password, accountName, color, emoji)

method addAccountsFromSeed*(self: Controller, seedPhrase: string, password: string, accountName: string, color: string, emoji: string): string =
  return self.walletAccountService.addAccountsFromSeed(seedPhrase, password, accountName, color, emoji)

method addWatchOnlyAccount*(self: Controller, address: string, accountName: string, color: string, emoji: string): string =
  return self.walletAccountService.addWatchOnlyAccount(address, accountName, color, emoji)

method deleteAccount*(self: Controller, address: string) =
  self.walletAccountService.deleteAccount(address)
