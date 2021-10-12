import NimQml
import io_interface, view, controller, item
import ../../../../app/boot/global_singleton

import ../../../../app_service/[main]
import ../../../../app_service/service/accounts/service_interface as accounts_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*[T](delegate: T,
  appService: AppService,
  accountsService: accounts_service.ServiceInterface): 
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, appService,
  accountsService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("onboardingModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("onboardingModule", self.viewVariant)
  self.controller.init()
  self.view.load()

  let generatedAccounts = self.controller.getGeneratedAccounts()
  var accounts: seq[Item]
  for acc in generatedAccounts:
    accounts.add(initItem(acc.id, acc.alias, acc.identicon, acc.address, acc.keyUid))

  self.view.setAccountList(accounts)

  self.moduleLoaded = true
  self.delegate.onboardingDidLoad()

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  discard

method setSelectedAccountId*[T](self: Module[T], id: string) =
  self.controller.setSelectedAccountId(id)

method storeSelectedAccountAndLogin*[T](self: Module[T], password: string) =
  self.controller.storeSelectedAccountAndLogin(password)