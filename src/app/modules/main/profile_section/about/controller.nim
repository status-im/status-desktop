import ./controller_interface
import io_interface
import ../../../../../app_service/service/about/service as about_service

# import ./item as item

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    aboutService: about_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface, aboutService: about_service.ServiceInterface): Controller =
  result = Controller()
  result.delegate = delegate
  result.aboutService = aboutService

method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method getAppVersion*(self: Controller): string =
  return self.aboutService.getAppVersion()

method getNodeVersion*(self: Controller): string =
  return self.aboutService.getNodeVersion()
