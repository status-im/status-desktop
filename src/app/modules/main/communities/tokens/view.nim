import NimQml, json, strutils, sequtils

import ./io_interface as community_tokens_module_interface
import ../../../shared_models/currency_amount
import ../../../../../app_service/common/conversion
import ../../../../../app_service/service/community/dto/community

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

  proc deployCollectible*(self: View, communityId: string, fromAddress: string, name: string, symbol: string, description: string, supply: float, infiniteSupply: bool, transferable: bool, selfDestruct: bool, chainId: int, imageCropInfoJson: string) {.slot.} =
    self.communityTokensModule.deployCollectibles(communityId, fromAddress, name, symbol, description, supply, infiniteSupply, transferable, selfDestruct, chainId, imageCropInfoJson)

  proc deployAssets*(self: View, communityId: string, fromAddress: string, name: string, symbol: string, description: string, supply: float, infiniteSupply: bool, decimals: int, chainId: int, imageCropInfoJson: string) {.slot.} =
    self.communityTokensModule.deployAssets(communityId, fromAddress, name, symbol, description, supply, infiniteSupply, decimals, chainId, imageCropInfoJson)

  proc airdropTokens*(self: View, communityId: string, tokensJsonString: string, walletsJsonString: string) {.slot.} =
    self.communityTokensModule.airdropTokens(communityId, tokensJsonString, walletsJsonString)

  proc computeAirdropFee*(self: View, communityId: string, tokensJsonString: string, walletsJsonString: string) {.slot.} =
    self.communityTokensModule.computeAirdropFee(communityId, tokensJsonString, walletsJsonString)

  proc selfDestructCollectibles*(self: View, communityId: string, collectiblesToBurnJsonString: string, contractUniqueKey: string) {.slot.} =
    self.communityTokensModule.selfDestructCollectibles(communityId, collectiblesToBurnJsonString, contractUniqueKey)

  proc burnTokens*(self: View, communityId: string, contractUniqueKey: string, amount: float) {.slot.} =
    self.communityTokensModule.burnTokens(communityId, contractUniqueKey, amount)

  proc deployFeeUpdated*(self: View, ethCurrency: QVariant, fiatCurrency: QVariant, errorCode: int) {.signal.}
  proc selfDestructFeeUpdated*(self: View, ethCurrency: QVariant, fiatCurrency: QVariant, errorCode: int) {.signal.}
  proc airdropFeesUpdated*(self: View, json: string) {.signal.}
  proc burnFeeUpdated*(self: View, ethCurrency: QVariant, fiatCurrency: QVariant, errorCode: int) {.signal.}

  proc computeDeployFee*(self: View, chainId: int, accountAddress: string, tokenType: int) {.slot.} =
    self.communityTokensModule.computeDeployFee(chainId, accountAddress, intToEnum(tokenType, TokenType.Unknown))

  proc computeSelfDestructFee*(self: View, collectiblesToBurnJsonString: string, contractUniqueKey: string) {.slot.} =
    self.communityTokensModule.computeSelfDestructFee(collectiblesToBurnJsonString, contractUniqueKey)

  proc computeBurnFee*(self: View, contractUniqueKey: string, amount: float) {.slot.} =
    self.communityTokensModule.computeBurnFee(contractUniqueKey, amount)

  proc updateDeployFee*(self: View, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: int) =
    self.deployFeeUpdated(newQVariant(ethCurrency), newQVariant(fiatCurrency), errorCode)

  proc updateBurnFee*(self: View, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: int) =
    self.burnFeeUpdated(newQVariant(ethCurrency), newQVariant(fiatCurrency), errorCode)

  proc updateSelfDestructFee*(self: View, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: int) =
    self.selfDestructFeeUpdated(newQVariant(ethCurrency), newQVariant(fiatCurrency), errorCode)

  proc updateAirdropFees*(self: View, args: JsonNode) =
    self.airdropFeesUpdated($args)

  proc deploymentStateChanged*(self: View, communityId: string, status: int, url: string) {.signal.}
  proc emitDeploymentStateChanged*(self: View, communityId: string, status: int, url: string) =
    self.deploymentStateChanged(communityId, status, url)

  proc remoteDestructStateChanged*(self: View, communityId: string, tokenName: string, status: int, url: string) {.signal.}
  proc emitRemoteDestructStateChanged*(self: View, communityId: string, tokenName: string, status: int, url: string) =
    self.remoteDestructStateChanged(communityId, tokenName, status, url)

  proc burnStateChanged*(self: View, communityId: string, tokenName: string, status: int, url: string) {.signal.}
  proc emitBurnStateChanged*(self: View, communityId: string, tokenName: string, status: int, url: string) =
    self.burnStateChanged(communityId, tokenName, status, url)

  proc airdropStateChanged*(self: View, communityId: string, tokenName: string, chainName: string, status: int, url: string) {.signal.}
  proc emitAirdropStateChanged*(self: View, communityId: string, tokenName: string, chainName: string, status: int, url: string) =
    self.airdropStateChanged(communityId, tokenName, chainName, status, url)
