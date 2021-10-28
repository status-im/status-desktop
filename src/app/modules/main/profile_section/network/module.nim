import NimQml, Tables
import json, sequtils
import status/settings
import status/types/[setting]
import status/status

import ./io_interface, ./view, ./controller
import ../../../../core/global_singleton
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/network/service as network_service

export io_interface

const defaultNetworks = @["mainnet_rpc", "testnet_rpc", "rinkeby_rpc", "goerli_rpc", "xdai_rpc", "poa_rpc" ]

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

# Forward declaration
method getCurrentNetworkDetails*[T](self: Module[T]): NetworkDetails

proc newModule*[T](delegate: T, settingsService: settings_service.ServiceInterface, networkService: network_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, settingsService, networkService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("networkModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  let networkDetails = self.getCurrentNetworkDetails()
  self.view.setNetworkName(networkDetails.name)
  self.view.setNetwork(networkDetails.id)

  let networks = self.controller.getNetworks()
  let customNetworks = networks.filterIt(it.id notin defaultNetworks)
  self.view.setCustomNetworks(customNetworks)

  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method getCurrentNetworkDetails*[T](self: Module[T]): NetworkDetails =
  return self.controller.getCurrentNetworkDetails()

method addCustomNetwork*[T](self: Module[T], name: string, endpoint: string, networkId: int, networkType: string) =
  self.controller.addCustomNetwork(name, endpoint, networkId, networkType)

method changeNetwork*[T](self: Module[T], network: string) =
  self.controller.changeNetwork(network)