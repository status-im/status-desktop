import NimQml, json, strutils, sequtils

import ./io_interface as community_tokens_module_interface
import app/modules/shared_models/currency_amount

QtObject:
  type
    View* = ref object of QObject
      communityTokensModule: community_tokens_module_interface.AccessInterface
      ownerTokenDetails: string

  proc load*(self: View) =
    discard

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(communityTokensModule: community_tokens_module_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.communityTokensModule = communityTokensModule

  proc authenticateAndTransfer*(self: View) {.slot.} =
    self.communityTokensModule.authenticateAndTransfer()

  proc computeDeployCollectiblesFee*(self: View, uuid: string, communityId: string, fromAddress: string, name: string,
    symbol: string, description: string, supply: string, infiniteSupply: bool, transferable: bool, selfDestruct: bool,
    chainId: int, imageCropInfoJson: string) {.slot.} =
      self.communityTokensModule.computeDeployCollectiblesFee(uuid, communityId, fromAddress, name, symbol, description,
        supply, infiniteSupply, transferable, selfDestruct, chainId, imageCropInfoJson)

  proc computeDeployAssetsFee*(self: View, uuid: string, communityId: string, fromAddress: string, name: string,
    symbol: string, description: string, supply: string, infiniteSupply: bool, decimals: int, chainId: int,
    imageCropInfoJson: string) {.slot.} =
      self.communityTokensModule.computeDeployAssetsFee(uuid, communityId, fromAddress, name, symbol, description, supply,
        infiniteSupply, decimals, chainId, imageCropInfoJson)

  proc computeDeployTokenOwnerFee*(self:View, uuid: string, communityId: string, fromAddress: string, ownerName: string,
    ownerSymbol: string, ownerDescription: string, masterName: string, masterSymbol: string, masterDescription: string,
    chainId: int, imageCropInfoJson: string) {.slot.} =
      self.communityTokensModule.computeDeployTokenOwnerFee(uuid, communityId, fromAddress, ownerName, ownerSymbol,
      ownerDescription, masterName, masterSymbol, masterDescription, chainId, imageCropInfoJson)

  proc removeCommunityToken*(self: View, communityId: string, chainId: int, address: string) {.slot.} =
    self.communityTokensModule.removeCommunityToken(communityId, chainId, address)

  proc refreshCommunityToken*(self: View, chainId: int, address: string) {.slot.} =
    self.communityTokensModule.refreshCommunityToken(chainId, address)

  proc airdropTokens*(self: View, communityId: string, tokensJsonString: string, walletsJsonString: string, addressFrom: string) {.slot.} =
    self.communityTokensModule.airdropTokens(communityId, tokensJsonString, walletsJsonString, addressFrom)

  proc computeAirdropFee*(self: View, communityId: string, tokensJsonString: string, walletsJsonString: string, addressFrom: string, requestId: string) {.slot.} =
    self.communityTokensModule.computeAirdropFee(communityId, tokensJsonString, walletsJsonString, addressFrom, requestId)

  proc selfDestructCollectibles*(self: View, communityId: string, collectiblesToBurnJsonString: string, contractUniqueKey: string, addressFrom: string) {.slot.} =
    self.communityTokensModule.selfDestructCollectibles(communityId, collectiblesToBurnJsonString, contractUniqueKey, addressFrom)

  proc burnTokens*(self: View, communityId: string, contractUniqueKey: string, amount: string, addressFrom: string) {.slot.} =
    self.communityTokensModule.burnTokens(communityId, contractUniqueKey, amount, addressFrom)

  proc setSigner*(self: View, communityId: string, chainId: int, contractAddress: string, addressFrom: string) {.slot.} =
    self.communityTokensModule.setSigner(communityId, chainId, contractAddress, addressFrom)

  proc selfDestructFeeUpdated*(self: View, ethCurrency: QVariant, fiatCurrency: QVariant, errorCode: int, responseId: string) {.signal.}
  proc airdropFeesUpdated*(self: View, json: string) {.signal.}
  proc burnFeeUpdated*(self: View, ethCurrency: QVariant, fiatCurrency: QVariant, errorCode: int, responseId: string) {.signal.}
  proc setSignerFeeUpdated*(self: View, ethCurrency: QVariant, fiatCurrency: QVariant, errorCode: int, responseId: string) {.signal.}
  proc ownerTokenReceived*(self: View, communityId: string, communityName: string, chainId: int, contractAddress: string) {.signal.}
  proc communityTokenReceived*(self: View, name: string, symbol: string, image: string, communityId: string, communityName: string, balance: string, chainId: int, txHash: string, isFirst: bool, tokenType: int, accountName: string, accountAddress: string) {.signal.}
  proc setSignerStateChanged*(self: View, communityId: string, communityName: string, status: int, url: string) {.signal.}
  proc ownershipNodeLost*(self: View, communityId: string, communityName: string) {.signal.}
  proc sendOwnerTokenStateChanged*(self: View, tokenName: string, status: int, url: string) {.signal.}


  proc computeSetSignerFee*(self: View, chainId: int, contractAddress: string, addressFrom: string, requestId: string) {.slot.} =
    self.communityTokensModule.computeSetSignerFee(chainId, contractAddress, addressFrom, requestId)

  proc computeSelfDestructFee*(self: View, collectiblesToBurnJsonString: string, contractUniqueKey: string, addressFrom: string, requestId: string) {.slot.} =
    self.communityTokensModule.computeSelfDestructFee(collectiblesToBurnJsonString, contractUniqueKey, addressFrom, requestId)

  proc computeBurnFee*(self: View, contractUniqueKey: string, amount: string, addressFrom: string, requestId: string) {.slot.} =
    self.communityTokensModule.computeBurnFee(contractUniqueKey, amount, addressFrom, requestId)

  proc declineOwnership*(self: View, communityId: string) {.slot.} =
    self.communityTokensModule.declineOwnership(communityId)


  proc updateBurnFee*(self: View, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: int, responseId: string) =
    self.burnFeeUpdated(newQVariant(ethCurrency), newQVariant(fiatCurrency), errorCode, responseId)

  proc updateSetSignerFee*(self: View, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: int, responseId: string) =
    self.setSignerFeeUpdated(newQVariant(ethCurrency), newQVariant(fiatCurrency), errorCode, responseId)

  proc updateSelfDestructFee*(self: View, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: int, responseId: string) =
    self.selfDestructFeeUpdated(newQVariant(ethCurrency), newQVariant(fiatCurrency), errorCode, responseId)

  proc updateAirdropFees*(self: View, args: JsonNode) =
    self.airdropFeesUpdated($args)


  proc remoteDestructStateChanged*(self: View, communityId: string, tokenName: string, status: int, url: string) {.signal.}
  proc emitRemoteDestructStateChanged*(self: View, communityId: string, tokenName: string, status: int, url: string) =
    self.remoteDestructStateChanged(communityId, tokenName, status, url)

  proc burnStateChanged*(self: View, communityId: string, tokenName: string, status: int, url: string) {.signal.}
  proc emitBurnStateChanged*(self: View, communityId: string, tokenName: string, status: int, url: string) =
    self.burnStateChanged(communityId, tokenName, status, url)

  proc airdropStateChanged*(self: View, communityId: string, tokenName: string, chainName: string, status: int, url: string) {.signal.}
  proc emitAirdropStateChanged*(self: View, communityId: string, tokenName: string, chainName: string, status: int, url: string) =
    self.airdropStateChanged(communityId, tokenName, chainName, status, url)



  proc emitOwnerTokenReceived*(self: View, communityId: string, communityName: string, chainId: int, contractAddress: string) =
    self.ownerTokenReceived(communityId, communityName, chainId, contractAddress)

  proc emitCommunityTokenReceived*(self: View, name: string, symbol: string, image: string, communityId: string, communityName: string, balance: string, chainId: int, txHash: string, isFirst: bool, tokenType: int, accountName: string, accountAddress: string) =
    self.communityTokenReceived(name, symbol, image, communityId, communityName, balance, chainId, txHash, isFirst, tokenType, accountName, accountAddress)

  proc emitSetSignerStateChanged*(self: View, communityId: string, communityName: string, status: int, url: string) =
    self.setSignerStateChanged(communityId, communityName, status, url)

  proc emitOwnershipLost*(self: View, communityId: string, communityName: string) =
    self.ownershipNodeLost(communityId, communityName)

  proc emitSendOwnerTokenStateChanged*(self: View, tokenName: string, status: int, url: string) =
    self.sendOwnerTokenStateChanged(tokenName, status, url)

  proc asyncGetOwnerTokenDetails*(self: View, communityId: string) {.slot.} =
    self.communityTokensModule.asyncGetOwnerTokenDetails(communityId)

  proc ownerTokenDetailsChanged*(self: View) {.signal.}
  proc getOwnerTokenDetails*(self: View): string {.slot.} =
    return self.ownerTokenDetails
  proc setOwnerTokenDetails*(self: View, ownerTokenDetails: string) =
    self.ownerTokenDetails = ownerTokenDetails
    self.ownerTokenDetailsChanged()

  QtProperty[string] ownerTokenDetails:
    read = getOwnerTokenDetails
    notify = ownerTokenDetailsChanged

  proc suggestedRoutesReady(self: View, uuid: string, ethCurrency: QVariant, fiatCurrency: QVariant, errCode: string, errDescription: string) {.signal.}
  proc emitSuggestedRoutesReadySignal*(self: View, uuid: string, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errCode: string, errDescription: string) =
    self.suggestedRoutesReady(uuid, newQVariant(ethCurrency), newQVariant(fiatCurrency), errCode, errDescription)

  proc stopUpdatesForSuggestedRoute*(self: View) {.slot.} =
    self.communityTokensModule.stopUpdatesForSuggestedRoute()