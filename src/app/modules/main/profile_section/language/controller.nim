import ./controller_interface
import io_interface
import ../../../../../app_service/service/language/service_interface as language_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    languageService: language_service.ServiceInterface

method init*(self: Controller) =
  discard

proc newController*(delegate: io_interface.AccessInterface, languageService: language_service.ServiceInterface): 
  Controller =
  result = Controller()
  result.delegate = delegate
  result.languageService = languageService

method delete*(self: Controller) =
  discard

method changeLanguage*(self: Controller, locale: string) =
  self.languageService.setLanguage(locale)
