import ./controller_interface
import io_interface
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    walletAccountService: wallet_account_service.ServiceInterface

proc newController*(
  delegate: io_interface.AccessInterface,
  walletAccountService: wallet_account_service.ServiceInterface
): Controller =
  result = Controller()
  result.delegate = delegate
  result.walletAccountService = walletAccountService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  discard

method getWalletAccount*(self: Controller, accountIndex: int): wallet_account_service.WalletAccountDto =
  return self.walletAccountService.getWalletAccount(accountIndex)

method getIndex*(self: Controller, address: string): int =
  return self.walletAccountService.getIndex(address)