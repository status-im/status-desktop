import NimQml
import io_interface
import ../io_interface as delegate_interface
import view, controller, account_item
import ../../../../app/boot/global_singleton

import ../../../../app_service/[main]
import ../../../../app_service/service/accounts/service_interface as accounts_service

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface,
  appService: AppService,
  accountsService: accounts_service.ServiceInterface): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, appService, accountsService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("loginModule", result.viewVariant)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

proc extractImages(self: Module, account: AccountDto, thumbnailImage: var string,
  largeImage: var string) =
  for img in account.images:
    if(img.imgType == "thumbnail"):
      thumbnailImage = img.uri
    elif(img.imgType == "large"):
      largeImage = img.uri

method load*(self: Module) =
  self.view.load()

  let openedAccounts = self.controller.getOpenedAccounts()
  if(openedAccounts.len > 0):
    var accounts: seq[AccountItem]
    for acc in openedAccounts:
      var thumbnailImage: string
      var largeImage: string
      self.extractImages(acc, thumbnailImage, largeImage)
      accounts.add(newAccountItem(acc.name, acc.identicon, acc.keyUid, 
      thumbnailImage, largeImage))

    self.view.setAccountsList(accounts)

    # set the first account as a slected one
    let selected = openedAccounts[0]
    var thumbnailImage: string
    var largeImage: string
    self.extractImages(selected, thumbnailImage, largeImage)
  
    self.view.setSelectedAccount(selected.name, selected.identicon, selected.keyUid, 
    thumbnailImage, largeImage)

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.loginDidLoad()