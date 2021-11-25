import ./controller_interface
import io_interface
import ../../../../../app_service/service/accounts/service as accounts_service
import ../../../../../app_service/service/privacy/service as privacy_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    accountsService: accounts_service.ServiceInterface
    privacyService: privacy_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface, privacyService: privacy_service.ServiceInterface, 
  accountsService: accounts_service.ServiceInterface): Controller =
  result = Controller()
  result.delegate = delegate
  result.accountsService = accountsService
  result.privacyService = privacyService

method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method getLinkPreviewWhitelist*(self: Controller): string =
  return self.privacyService.getLinkPreviewWhitelist()

method changePassword*(self: Controller, password: string, newPassword: string): bool =
  let loggedInAccount = self.accountsService.getLoggedInAccount()
  return self.privacyService.changePassword(loggedInAccount.keyUid, password, newPassword)
