import io_interface
import ../../../../../app_service/service/language/service as language_service
import ../../../../../app/core/eventemitter

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    languageService: language_service.Service

proc init*(self: Controller) =
  self.events.on(SIGNAL_LOCALE_UPDATE) do(e: Args):
    let args = LocaleUpdatedArgs(e)
    self.delegate.onCurrentLocaleChanged(args.locale)

proc newController*(delegate: io_interface.AccessInterface,
    events: EventEmitter, languageService: language_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.languageService = languageService

proc delete*(self: Controller) =
  discard

proc changeLocale*(self: Controller, locale: string) =
  self.languageService.setLanguage(locale)

proc getLocales*(self: Controller): seq[string] =
  self.languageService.locales()

proc getCurrentLocale*(self: Controller): string =
  language_service.currentLocale()
