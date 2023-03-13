import NimQml, json, strutils, sequtils

import ./io_interface as community_tokens_module_interface

QtObject:
  type
    View* = ref object of QObject
      communityTokensModule: community_tokens_module_interface.AccessInterface
      deployFee: string

  proc load*(self: View) =
    discard

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(communityTokensModule: community_tokens_module_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.communityTokensModule = communityTokensModule

  proc deployCollectible*(self: View, communityId: string, fromAddress: string, name: string, symbol: string, description: string, supply: int, infiniteSupply: bool, transferable: bool, selfDestruct: bool, chainId: int, image: string) {.slot.} =
    self.communityTokensModule.deployCollectible(communityId, fromAddress, name, symbol, description, supply, infiniteSupply, transferable, selfDestruct, chainId, image)

  proc airdropCollectibles*(self: View, communityId: string, collectiblesJsonString: string, walletsJsonString: string) {.slot.} =
    self.communityTokensModule.airdropCollectibles(communityId, collectiblesJsonString, walletsJsonString)

  proc deployFeeUpdated*(self: View) {.signal.}

  proc computeDeployFee*(self: View, chainId: int) {.slot.} =
    self.deployFee = self.communityTokensModule.computeDeployFee(chainId)
    self.deployFeeUpdated()

  proc getDeployFee(self: View): QVariant {.slot.} =
    return newQVariant(self.deployFee)

  QtProperty[QVariant] deployFee:
    read = getDeployFee
    notify = deployFeeUpdated

