import NimQml, json, strutils, sequtils

import ./io_interface as minting_module_interface
import models/token_model
import models/token_item

QtObject:
  type
    View* = ref object of QObject
      mintingModule: minting_module_interface.AccessInterface
      model: TokenModel
      modelVariant: QVariant

  proc load*(self: View) =
    discard

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(mintingModule: minting_module_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.mintingModule = mintingModule
    result.model = newTokenModel()
    result.modelVariant = newQVariant(result.model)

  proc mintCollectible*(self: View, name: string, description: string, supply: int, transferable: bool, selfDestruct: bool, network: string) {.slot.} =
    self.mintingModule.mintCollectible(name, description, supply, transferable, selfDestruct, network)

  proc setItems*(self: View, items: seq[TokenItem]) =
    self.model.setItems(items)

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] tokensModel:
    read = getModel




