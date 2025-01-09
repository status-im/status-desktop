import NimQml

import ./io_interface, ./view
import ./controller as all_collectibles_controller
import ../io_interface as delegate_interface

import app/global/global_singleton
import app/core/eventemitter
import app/modules/shared_modules/collectibles/controller as collectibles_controller
import app/modules/shared_models/collectibles_model as collectibles_model
import app_service/service/collectible/service as collectible_service
import app_service/service/network/service as network_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/settings/service as settings_service

import backend/collectibles as backend_collectibles

export io_interface

type Module* = ref object of io_interface.AccessInterface
  delegate: delegate_interface.AccessInterface
  events: EventEmitter
  view: View
  viewVariant: QVariant
  controller: all_collectibles_controller.Controller
  collectiblesController: collectibles_controller.Controller
  moduleLoaded: bool

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    collectibleService: collectible_service.Service,
    networkService: network_service.Service,
    walletAccountService: wallet_account_service.Service,
    settingsService: settings_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.controller = all_collectibles_controller.newController(
    result, events, collectibleService, networkService, walletAccountService,
    settingsService,
  )

  let collectiblesController = collectibles_controller.newController(
    requestId = int32(backend_collectibles.CollectiblesRequestID.AllCollectibles),
    loadType = collectibles_controller.LoadType.AutoLoadSingleUpdate,
    networkService = networkService,
    events = events,
  )
  result.collectiblesController = collectiblesController

  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.viewVariant.delete
  self.view.delete
  self.controller.delete
  self.collectiblesController.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty(
    "walletSectionAllCollectibles", self.viewVariant
  )

  self.events.on(SIGNAL_COLLECTIBLE_PREFERENCES_UPDATED) do(e: Args):
    let args = ResultArgs(e)
    self.view.collectiblePreferencesUpdated(args.success)

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc refreshCollectiblesFilter(self: Module) =
  let addresses = self.controller.getWalletAddresses()
  let chainIds = self.controller.getChainIds()
  self.collectiblesController.setFilterAddressesAndChains(addresses, chainIds)

method viewDidLoad*(self: Module) =
  self.refreshCollectiblesFilter()
  self.moduleLoaded = true
  self.delegate.allCollectiblesModuleDidLoad()

method setSelectedAccount*(self: Module, address: string) =
  self.collectiblesController.setSelectedAccount(address)

method getAllCollectiblesModel*(self: Module): collectibles_model.Model =
  return self.collectiblesController.getModel()

method refreshNetworks*(self: Module) =
  self.refreshCollectiblesFilter()

method refreshWalletAccounts*(self: Module) =
  self.refreshCollectiblesFilter()

method updateCollectiblePreferences*(
    self: Module, collectiblePreferencesJson: string
) {.slot.} =
  self.controller.updateCollectiblePreferences(collectiblePreferencesJson)

method getCollectiblePreferencesJson*(self: Module): string =
  return self.controller.getCollectiblePreferencesJson()

method getCollectibleGroupByCommunity*(self: Module): bool =
  return self.controller.getCollectibleGroupByCommunity()

method toggleCollectibleGroupByCommunity*(self: Module): bool =
  return self.controller.toggleCollectibleGroupByCommunity()

method getCollectibleGroupByCollection*(self: Module): bool =
  return self.controller.getCollectibleGroupByCollection()

method toggleCollectibleGroupByCollection*(self: Module): bool =
  return self.controller.toggleCollectibleGroupByCollection()
