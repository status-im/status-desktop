import NimQml, json

import ../../../../../app_service/service/community_tokens/service as tokens_service
import ../../../../../app_service/service/community_tokens/dto/deployment_parameters
import ../../../../core/eventemitter
import ../../../../global/global_singleton
import ../io_interface as parent_interface
import ./io_interface, ./view , ./controller
import ./models/token_item

export io_interface

type
  Module*  = ref object of io_interface.AccessInterface
    parent: parent_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    tempAddressFrom: string
    tempDeploymentParams: DeploymentParameters

proc newMintingModule*(
    parent: parent_interface.AccessInterface,
    events: EventEmitter,
    tokensService: tokens_service.Service): Module =
  result = Module()
  result.parent = parent
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newMintingController(result, events, tokensService)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("mintingModule", self.viewVariant)
  self.controller.init()
  self.view.load()
  # tested data
  var items: seq[TokenItem] = @[]
  let tok1 = token_item.initCollectibleTokenItem("", "Collect1", "Desc1", "", 100, false, true, true, "", MintingState.Minted)
  let tok2 = token_item.initCollectibleTokenItem("", "Collect2", "Desc2", "", 200, false, false, false, "", MintingState.Minted)
  items.add(tok1)
  items.add(tok2)
  self.view.setItems(items)

method mintCollectible*(self: Module, fromAddress: string, name: string, symbol: string, description: string,
                        supply: int, infiniteSupply: bool, transferable: bool, selfDestruct: bool, network: string) =
  self.tempAddressFrom = fromAddress
  self.tempDeploymentParams.name = name
  self.tempDeploymentParams.symbol = symbol
  self.tempDeploymentParams.description = description
  self.tempDeploymentParams.supply = supply
  self.tempDeploymentParams.infiniteSupply = infiniteSupply
  self.tempDeploymentParams.transferable = transferable
  self.tempDeploymentParams.remoteSelfDestruct = selfDestruct
  #network not used now
  if singletonInstance.userProfile.getIsKeycardUser():
    let keyUid = singletonInstance.userProfile.getKeyUid()
    self.controller.authenticateUser(keyUid)
  else:
    self.controller.authenticateUser()

method onUserAuthenticated*(self: Module, password: string) =
  defer: self.tempAddressFrom = ""
  defer: self.tempDeploymentParams = DeploymentParameters()
  if password.len == 0:
    discard
    #TODO signalize somehow
  else:
    self.controller.mintCollectibles(self.tempAddressFrom, password, self.tempDeploymentParams)