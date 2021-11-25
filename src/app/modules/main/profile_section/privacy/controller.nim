import ./controller_interface
import ../../../../../app_service/service/accounts/service as accounts_service
import ../../../../../app_service/service/privacy/service as privacy_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    accountsService: accounts_service.ServiceInterface
    privacyService: privacy_service.ServiceInterface

proc newController*[T](delegate: T, privacyService: privacy_service.ServiceInterface, accountsService: accounts_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.accountsService = accountsService
  result.privacyService = privacyService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method getLinkPreviewWhitelist*[T](self: Controller[T]): string =
  return self.privacyService.getLinkPreviewWhitelist()

method changePassword*[T](self: Controller[T], password: string, newPassword: string): bool =
  let loggedInAccount = self.accountsService.getLoggedInAccount()
  return self.privacyService.changePassword(loggedInAccount.keyUid, password, newPassword)
