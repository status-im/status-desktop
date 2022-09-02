import io_interface
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    walletAccountService: wallet_account_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  walletAccountService: wallet_account_service.Service
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

proc generateNewAccount*(self: Controller, password: string, accountName: string, color: string, emoji: string, path: string, derivedFrom: string): string =
  return self.walletAccountService.generateNewAccount(password, accountName, color, emoji, path, derivedFrom)

proc addAccountsFromPrivateKey*(self: Controller, privateKey: string, password: string, accountName: string, color: string, emoji: string): string =
  return self.walletAccountService.addAccountsFromPrivateKey(privateKey, password, accountName, color, emoji)

proc addAccountsFromSeed*(self: Controller, seedPhrase: string, password: string, accountName: string, color: string, emoji: string, path: string): string =
  return self.walletAccountService.addAccountsFromSeed(seedPhrase, password, accountName, color, emoji, path)

proc addWatchOnlyAccount*(self: Controller, address: string, accountName: string, color: string, emoji: string): string =
  return self.walletAccountService.addWatchOnlyAccount(address, accountName, color, emoji)

proc deleteAccount*(self: Controller, address: string) =
  self.walletAccountService.deleteAccount(address)

method getDerivedAddressList*(self: Controller, password: string, derivedFrom: string, path: string, pageSize: int, pageNumber: int)=
  self.walletAccountService.getDerivedAddressList(password, derivedFrom, path, pageSize, pageNumber)

method getDerivedAddressListForMnemonic*(self: Controller, mnemonic: string, path: string, pageSize: int, pageNumber: int) =
  self.walletAccountService.getDerivedAddressListForMnemonic(mnemonic, path, pageSize, pageNumber)

method getDerivedAddressForPrivateKey*(self: Controller, privateKey: string) =
  self.walletAccountService.getDerivedAddressForPrivateKey(privateKey)


