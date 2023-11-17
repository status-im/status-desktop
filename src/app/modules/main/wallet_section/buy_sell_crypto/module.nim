import NimQml, sequtils

import ./io_interface, ./view, ./item, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/transaction/cryptoRampDto

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    controller: Controller
    moduleLoaded: bool

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  transactionService: transaction_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.view = newView(result)
  result.controller = controller.newController(result, events, transactionService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.controller.delete

method updateCryptoServices*(self: Module, cryptoServices: seq[CryptoRampDto]) =
  let items = cryptoServices.map(proc (w: CryptoRampDto): item.Item = result = initItem(
    w.name,
    w.description,
    w.fees,
    w.logoUrl,
    w.siteUrl,
    w.hostname
  ))
  self.view.setItems(items)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionBuySellCrypto", newQVariant(self.view))
  self.controller.fetchCryptoServices()
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.buySellCryptoModuleDidLoad()
