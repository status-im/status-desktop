import NimQml, Tables

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton

import ../../../../../app_service/service/language/service as language_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, languageService: language_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, languageService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.languageModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method changeLanguage*(self: Module, locale: string) =
  self.controller.changeLanguage(locale)

method setIsDDMMYYDateFormat*(self: Module, isDDMMYYDateFormat: bool) =
  if(isDDMMYYDateFormat != singletonInstance.localAccountSensitiveSettings.getIsDDMMYYDateFormat()):
    singletonInstance.localAccountSensitiveSettings.setIsDDMMYYDateFormat(isDDMMYYDateFormat)

method setIs24hTimeFormat*(self: Module, is24hTimeFormat: bool) =
  if(is24hTimeFormat != singletonInstance.localAccountSensitiveSettings.getIs24hTimeFormat()):
    singletonInstance.localAccountSensitiveSettings.setIs24hTimeFormat(is24hTimeFormat)
