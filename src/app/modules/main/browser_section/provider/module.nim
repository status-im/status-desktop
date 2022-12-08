import NimQml
import io_interface
import view
import controller
import std/json
import ../../../../core/eventemitter

import ../io_interface as delegate_interface
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/provider/service as provider_service
import ../../../../global/global_singleton
export io_interface

# Shouldn't be public ever, user only within this module.
type TmpSendTransactionDetails = object
  payloadMethod: string
  requestType: string
  message: string

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    controller: Controller
    tmpSendTransactionDetails: TmpSendTransactionDetails

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  networkService: network_service.Service,
  providerService: provider_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.moduleLoaded = false
  result.controller = controller.newController(result, events, settingsService, networkService, providerService)

method delete*(self: Module) =
  self.controller.delete
  self.viewVariant.delete
  self.view.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("providerModule", self.viewVariant)
  self.view.dappsAddress = self.controller.getDappsAddress()
  let network = self.controller.getNetwork()
  self.view.chainId = network.chainId
  self.view.chainName = network.chainName
  self.view.load()
  self.controller.init()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method setDappsAddress*(self: Module, value: string) =
  self.controller.setDappsAddress(value)

method onDappAddressChanged*(self: Module, value: string) =
  self.view.dappsAddress = value

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.providerDidLoad()

method postMessage*(self: Module, payloadMethod: string, requestType: string, message: string) =
  self.controller.postMessage(payloadMethod, requestType, message)

method onPostMessage*(self: Module, payloadMethod: string, result: string, chainId: string) =
  self.view.postMessageResult(payloadMethod, result, chainId)

method ensResourceURL*(self: Module, ens: string, url: string): (string, string, string, string, bool) =
  return self.controller.ensResourceURL(ens, url)

method updateNetwork*(self: Module, network: NetworkDto) =
  self.view.chainId = network.chainId
  self.view.chainName = network.chainName

method authenticateToPostMessage*(self: Module, payloadMethod: string, requestType: string, message: string) {.slot.} =
  self.tmpSendTransactionDetails.payloadMethod = payloadMethod
  self.tmpSendTransactionDetails.requestType = requestType
  self.tmpSendTransactionDetails.message = message

  if singletonInstance.userProfile.getIsKeycardUser():
    let keyUid = singletonInstance.userProfile.getKeyUid()
    self.controller.authenticateUser(keyUid)
  else:
    self.controller.authenticateUser()

method onUserAuthenticated*(self: Module, password: string) =
  let jsonNode = parseJson(self.tmpSendTransactionDetails.message)

  if jsonNode.kind == JObject and jsonNode.contains("payload"):
    jsonNode["payload"]["password"] = %* password
    self.tmpSendTransactionDetails.message = $jsonNode
    self.postMessage(self.tmpSendTransactionDetails.payloadMethod,
                   self.tmpSendTransactionDetails.requestType,
                   self.tmpSendTransactionDetails.message)
