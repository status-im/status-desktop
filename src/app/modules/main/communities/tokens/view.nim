import NimQml, json, strutils, sequtils

import ./io_interface as community_tokens_module_interface
import ../../../shared_models/currency_amount

QtObject:
  type
    View* = ref object of QObject
      communityTokensModule: community_tokens_module_interface.AccessInterface

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

  proc selfDestructCollectibles*(self: View, communityId: string, collectiblesToBurnJsonString: string, contractUniqueKey: string) {.slot.} =
    self.communityTokensModule.selfDestructCollectibles(communityId, collectiblesToBurnJsonString, contractUniqueKey)

  proc deployFeeUpdated*(self: View, ethCurrency: QVariant, fiatCurrency: QVariant, errorCode: int) {.signal.}
  proc selfDestructFeeUpdated*(self: View, ethCurrency: QVariant, fiatCurrency: QVariant, errorCode: int) {.signal.}

  proc computeDeployFee*(self: View, chainId: int, accountAddress: string) {.slot.} =
    self.communityTokensModule.computeDeployFee(chainId, accountAddress)

  proc computeSelfDestructFee*(self: View, collectiblesToBurnJsonString: string, contractUniqueKey: string) {.slot.} =
    self.communityTokensModule.computeSelfDestructFee(collectiblesToBurnJsonString, contractUniqueKey)

  proc updateDeployFee*(self: View, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: int) =
    self.deployFeeUpdated(newQVariant(ethCurrency), newQVariant(fiatCurrency), errorCode)

  proc updateSelfDestructFee*(self: View, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: int) =
    self.selfDestructFeeUpdated(newQVariant(ethCurrency), newQVariant(fiatCurrency), errorCode)

  proc deploymentStateChanged*(self: View, communityId: string, status: int, url: string) {.signal.}
  proc emitDeploymentStateChanged*(self: View, communityId: string, status: int, url: string) =
    self.deploymentStateChanged(communityId, status, url)

  proc remoteDestructStateChanged*(self: View, communityId: string, tokenName: string, status: int, url: string) {.signal.}
  proc emitRemoteDestructStateChanged*(self: View, communityId: string, tokenName: string, status: int, url: string) =
    self.remoteDestructStateChanged(communityId, tokenName, status, url)