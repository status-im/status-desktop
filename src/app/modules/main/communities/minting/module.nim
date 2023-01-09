import NimQml, json

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

proc newMintingModule*(
    parent: parent_interface.AccessInterface,
    events: EventEmitter): Module =
  result = Module()
  result.parent = parent
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newMintingController(result, events)

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
  let tok1 = token_item.initCollectibleTokenItem("", "Collect1", "Desc1", "", 100, true, true, "", MintingState.Minted)
  let tok2 = token_item.initCollectibleTokenItem("", "Collect2", "Desc2", "", 200, false, false, "", MintingState.Minted)
  items.add(tok1)
  items.add(tok2)
  self.view.setItems(items)

method mintCollectible*(self: Module, name: string, description: string, supply: int, transferable: bool,
                      selfDestruct: bool, network: string) =
  echo "Minting pressed"
  echo "Name ", name
  echo "Desc ", description
  echo "Supply ", supply
  echo "Trans ", transferable
  echo "Self-destruct ", selfDestruct
  echo "Network ", network