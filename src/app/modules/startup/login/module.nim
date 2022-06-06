import NimQml
import io_interface
import ../io_interface as delegate_interface
import view, controller, item
import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/keychain/service as keychain_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/keycard/service as keycard_service

import ../../shared_modules/keycard/module as keycard_module

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool
    keycardModule: keycard_module.Module

proc newModule*(delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  keychainService: keychain_service.Service,
  keycardService: keycard_service.Service,
  accountsService: accounts_service.Service):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, keychainService,
  accountsService)
  result.moduleLoaded = false

  result.keycardModule = keycard_module.newModule(events, keycardService, accountsService)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete
  self.keycardModule.delete

proc extractImages(self: Module, account: AccountDto, thumbnailImage: var string,
  largeImage: var string) =
  for img in account.images:
    if(img.imgType == "thumbnail"):
      thumbnailImage = img.uri
    elif(img.imgType == "large"):
      largeImage = img.uri

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("loginModule", self.viewVariant)
  self.controller.init()
  self.keycardModule.init()
  self.view.load()

  let openedAccounts = self.controller.getOpenedAccounts()
  if(openedAccounts.len > 0):
    var items: seq[Item]
    for acc in openedAccounts:
      var thumbnailImage: string
      var largeImage: string
      self.extractImages(acc, thumbnailImage, largeImage)
      items.add(initItem(acc.name, thumbnailImage, largeImage,
      acc.keyUid, acc.colorHash, acc.colorId))

    self.view.setModelItems(items)

    # set the first account as slected one
    self.controller.setSelectedAccountKeyUid(items[0].getKeyUid())
    self.setSelectedAccount(items[0])

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.loginDidLoad()

method setSelectedAccount*(self: Module, item: Item) =
  self.controller.setSelectedAccountKeyUid(item.getKeyUid())
  self.view.setSelectedAccount(item)

method login*(self: Module, password: string) =
  self.controller.login(password)

method emitAccountLoginError*(self: Module, error: string) =
  self.view.emitAccountLoginError(error)

method emitObtainingPasswordError*(self: Module, errorDescription: string) =
  self.view.emitObtainingPasswordError(errorDescription)

method emitObtainingPasswordSuccess*(self: Module, password: string) =
  self.view.emitObtainingPasswordSuccess(password)

method getKeycardModule*(self: Module): QVariant =
  self.keycardModule.getModuleAsVariant()