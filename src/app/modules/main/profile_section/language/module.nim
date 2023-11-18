import NimQml, tables, chronicles

import io_interface, view, controller, item, model, locale_table
import ../io_interface as delegate_interface
import ../../../../../app/core/eventemitter

import ../../../../../app_service/service/language/service as language_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface,
    events: EventEmitter, languageService: language_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, languageService)
  result.moduleLoaded = false

proc populateLanguageModel(self: Module) =
  var items: seq[Item]

  for locale in self.controller.getLanguages():
    if localeDescriptionTable.contains(locale):
      let localeDescr = localeDescriptionTable[locale]
      items.add(initItem(
        locale = locale,
        name = localeDescr.name,
        native = localeDescr.native,
        flag = localeDescr.flag,
        state = localeDescr.state
      ))
    else:
      warn "missing locale details", locale

  self.view.model().setItems(items)

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.populateLanguageModel()
  self.view.setLanguage(self.controller.getCurrentLanguage())

  self.moduleLoaded = true
  self.delegate.languageModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method changeLanguage*(self: Module, language: string) =
  self.controller.changeLanguage(language)

method onCurrentLanguageChanged*(self: Module, language: string) =
  self.view.setLanguage(language)


