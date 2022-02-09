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

method update*(self: Controller, address: string, accountName: string, color: string) =
  self.walletAccountService.updateWalletAccount(address, accountName, color)
