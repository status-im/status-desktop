import io_interface
import ../../../../../app_service/service/language/service as language_service


type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    languageService: language_service.Service

proc init*(self: Controller) =
  discard

proc newController*(delegate: io_interface.AccessInterface, languageService: language_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.languageService = languageService

proc delete*(self: Controller) =
  discard

proc changeLanguage*(self: Controller, locale: string) =
  self.languageService.setLanguage(locale)

proc getLocales*(self: Controller): seq[string] =
  self.languageService.locales()
