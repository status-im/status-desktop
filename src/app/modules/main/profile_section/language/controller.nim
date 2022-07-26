import io_interface
import ../../../../../app_service/service/language/service as language_service
import ../../../../../app/core/eventemitter

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    languageService: language_service.Service

proc init*(self: Controller) =
  self.events.on(SIGNAL_LANGUAGE_UPDATE) do(e: Args):
    let args = LanguageUpdatedArgs(e)
    self.delegate.onCurrentLanguageChanged(args.language)

proc newController*(delegate: io_interface.AccessInterface,
    events: EventEmitter, languageService: language_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.languageService = languageService

proc delete*(self: Controller) =
  discard

proc changeLanguage*(self: Controller, language: string) =
  self.languageService.setLanguage(language)

proc getLanguages*(self: Controller): seq[string] =
  self.languageService.languages()

proc getCurrentLanguage*(self: Controller): string =
  language_service.currentLanguage()
