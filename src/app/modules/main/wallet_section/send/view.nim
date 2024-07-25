import NimQml, Tables, json, sequtils, strutils, stint, options, chronicles
import uuids

import ./io_interface, ./network_route_model, ./network_route_item, ./suggested_route_item, ./transaction_routes
import app/modules/shared_models/collectibles_model as collectibles
import app/modules/shared_models/collectibles_nested_model as nested_collectibles
import app_service/service/network/service as network_service
import app_service/service/transaction/dto as transaction_dto

import app_service/common/utils as common_utils
import app_service/service/eth/utils as eth_utils
from backend/eth import ExtraKeyPackId

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      # list of collectibles owned by the selected sender account
      collectiblesModel: collectibles.Model
      nestedCollectiblesModel: nested_collectibles.Model
      # for send modal
      fromNetworksRouteModel: NetworkRouteModel
      toNetworksRouteModel: NetworkRouteModel
      transactionRoutes: TransactionRoutes
      errCode: string
      errDescription: string
      selectedAssetKey: string
      selectedToAssetKey: string
      showUnPreferredChains: bool
      sendType: transaction_dto.SendType
      selectedTokenIsOwnerToken: bool
      selectedTokenName: string
      selectedRecipient: string
      selectedSenderAccountAddress: string
      # for receive modal
      selectedReceiveAccountAddress: string

  # Forward declaration
  proc updateNetworksDisabledChains(self: View)
  proc updateNetworksTokenBalance(self: View)

  proc delete*(self: View) =
    self.fromNetworksRouteModel.delete
    self.toNetworksRouteModel.delete
    self.transactionRoutes.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.fromNetworksRouteModel = newNetworkRouteModel()
    result.toNetworksRouteModel = newNetworkRouteModel()
    result.transactionRoutes = newTransactionRoutes()
    result.collectiblesModel = delegate.getCollectiblesModel()
    result.nestedCollectiblesModel = delegate.getNestedCollectiblesModel()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc selectedSenderAccountAddressChanged*(self: View) {.signal.}
  proc getSelectedSenderAccountAddress*(self: View): string {.slot.} =
    return self.selectedSenderAccountAddress
  proc setSelectedSenderAccountAddress*(self: View, address: string) {.slot.} =
    self.selectedSenderAccountAddress = address
    self.updateNetworksTokenBalance()
    self.selectedSenderAccountAddressChanged()
  QtProperty[string] selectedSenderAccountAddress:
    read = getSelectedSenderAccountAddress
    notify = selectedSenderAccountAddressChanged

  proc collectiblesModelChanged*(self: View) {.signal.}
  proc getCollectiblesModel(self: View): QVariant {.slot.} =
    return newQVariant(self.collectiblesModel)
  QtProperty[QVariant] collectiblesModel:
    read = getCollectiblesModel
    notify = collectiblesModelChanged

  proc nestedCollectiblesModelChanged*(self: View) {.signal.}
  proc getNestedCollectiblesModel(self: View): QVariant {.slot.} =
    return newQVariant(self.nestedCollectiblesModel)
  QtProperty[QVariant] nestedCollectiblesModel:
    read = getNestedCollectiblesModel
    notify = nestedCollectiblesModelChanged

  proc selectedReceiveAccountAddressChanged*(self: View) {.signal.}
  proc getSelectedReceiveAccountAddress*(self: View): string {.slot.} =
    return self.selectedReceiveAccountAddress
  proc setSelectedReceiveAccountAddress*(self: View, address: string) {.slot.} =
    self.selectedReceiveAccountAddress = address
    self.selectedReceiveAccountAddressChanged()
  QtProperty[string] selectedReceiveAccountAddress:
    read = getSelectedReceiveAccountAddress
    notify = selectedReceiveAccountAddressChanged

  proc fromNetworksRouteModelChanged*(self: View) {.signal.}
  proc getfromNetworksRouteModel(self: View): QVariant {.slot.} =
    return newQVariant(self.fromNetworksRouteModel)
  QtProperty[QVariant] fromNetworksRouteModel:
    read = getfromNetworksRouteModel
    notify = fromNetworksRouteModelChanged

  proc toNetworksRouteModelChanged*(self: View) {.signal.}
  proc gettoNetworksRouteModel(self: View): QVariant {.slot.} =
    return newQVariant(self.toNetworksRouteModel)
  QtProperty[QVariant] toNetworksRouteModel:
    read = gettoNetworksRouteModel
    notify = toNetworksRouteModelChanged

  proc selectedAssetKeyChanged*(self: View) {.signal.}
  proc getSelectedAssetKey*(self: View): string {.slot.} =
    return self.selectedAssetKey
  proc setSelectedAssetKey(self: View, assetKey: string) {.slot.} =
    self.selectedAssetKey = assetKey
    self.updateNetworksTokenBalance()
    self.selectedAssetKeyChanged()
  QtProperty[string] selectedAssetKey:
    write = setSelectedAssetKey
    read = getSelectedAssetKey
    notify = selectedAssetKeyChanged

  proc selectedToAssetKeyChanged*(self: View) {.signal.}
  proc getSelectedToAssetKey*(self: View): string {.slot.} =
    return self.selectedToAssetKey
  proc setSelectedToAssetKey(self: View, assetKey: string) {.slot.} =
    self.selectedToAssetKey = assetKey
    self.updateNetworksTokenBalance()
    self.selectedToAssetKeyChanged()
  QtProperty[string] selectedToAssetKey:
    write = setSelectedToAssetKey
    read = getSelectedToAssetKey
    notify = selectedToAssetKeyChanged

  proc showUnPreferredChainsChanged*(self: View) {.signal.}
  proc getShowUnPreferredChains(self: View): bool {.slot.} =
    return self.showUnPreferredChains
  proc toggleShowUnPreferredChains*(self: View) {.slot.} =
    self.showUnPreferredChains = not self.showUnPreferredChains
    self.updateNetworksDisabledChains()
    self.showUnPreferredChainsChanged()
  QtProperty[bool] showUnPreferredChains:
    read = getShowUnPreferredChains
    notify = showUnPreferredChainsChanged

  proc sendTypeChanged*(self: View) {.signal.}
  proc getSendType(self: View): int {.slot.} =
    return ord(self.sendType)
  proc setSendType(self: View, sendType: int) {.slot.} =
    self.sendType = (SendType)sendType
    self.sendTypeChanged()
  QtProperty[int] sendType:
    write = setSendType
    read = getSendType
    notify = sendTypeChanged

  proc selectedRecipientChanged*(self: View) {.signal.}
  proc getSelectedRecipient(self: View): string {.slot.} =
    return self.selectedRecipient
  proc setSelectedRecipient(self: View, selectedRecipient: string) {.slot.} =
    self.selectedRecipient = selectedRecipient
    self.selectedRecipientChanged()
  QtProperty[string] selectedRecipient:
    read = getSelectedRecipient
    write = setSelectedRecipient
    notify = selectedRecipientChanged

  proc setSelectedTokenIsOwnerToken(self: View, isOwnerToken: bool) {.slot.} =
    self.selectedTokenIsOwnerToken = isOwnerToken

  proc setSelectedTokenName(self: View, tokenName: string) {.slot.} =
    self.selectedTokenName = tokenName

  proc updateNetworksDisabledChains(self: View) =
    # if the setting to show unpreferred chains is toggled, add all unpreferred chains to disabled chains list
    if not self.showUnPreferredChains:
      self.toNetworksRouteModel.disableRouteUnpreferredChains()
    else:
      self.toNetworksRouteModel.enableRouteUnpreferredChains()

  proc updateNetworksTokenBalance(self: View) =
    for chainId in self.toNetworksRouteModel.getAllNetworksChainIds():
      self.fromNetworksRouteModel.updateTokenBalanceForSymbol(chainId, self.delegate.getTokenBalance(self.selectedSenderAccountAddress, chainId, self.selectedAssetKey))
      self.toNetworksRouteModel.updateTokenBalanceForSymbol(chainId, self.delegate.getTokenBalance(self.selectedSenderAccountAddress, chainId, self.selectedAssetKey))

  proc setNetworkItems*(self: View, fromNetworks: seq[NetworkRouteItem], toNetworks: seq[NetworkRouteItem]) =
    self.fromNetworksRouteModel.setItems(fromNetworks)
    self.toNetworksRouteModel.setItems(toNetworks)

  proc transactionSent*(self: View, chainId: int, txHash: string, uuid: string, error: string) {.signal.}
  proc sendTransactionSentSignal*(self: View, chainId: int, txHash: string, uuid: string, error: string) =
    self.transactionSent(chainId, txHash, uuid, error)

  proc parseChainIds(chainIds: string): seq[int] =
    var parsedChainIds: seq[int] = @[]
    for chainId in chainIds.split(':'):
      parsedChainIds.add(chainId.parseInt())
    return parsedChainIds

  proc authenticateAndTransfer*(self: View, uuid: string) {.slot.} =
    self.delegate.authenticateAndTransfer(self.selectedSenderAccountAddress, self.selectedRecipient, self.selectedAssetKey,
      self.selectedToAssetKey, uuid, self.sendType, self.selectedTokenName, self.selectedTokenIsOwnerToken)

  proc suggestedRoutesReady*(self: View, suggestedRoutes: QVariant, errCode: string, errDescription: string) {.signal.}
  proc setTransactionRoute*(self: View, routes: TransactionRoutes, errCode: string, errDescription: string) =
    self.transactionRoutes = routes
    self.errCode = errCode
    self.errDescription = errDescription
    self.suggestedRoutesReady(newQVariant(self.transactionRoutes), errCode, errDescription)

  proc suggestedRoutes*(self: View, amountIn: string, amountOut: string, extraParamsJson: string) {.slot.} =
    var extraParamsTable: Table[string, string]
    try:
      if extraParamsJson.len > 0:
        for key, value in parseJson(extraParamsJson):
          if key == ExtraKeyPackId:
            let bigPackId = common_utils.stringToUint256(value.getStr())
            let packIdHex = "0x" & eth_utils.stripLeadingZeros(bigPackId.toHex)
            extraParamsTable[key] = packIdHex
          else:
            extraParamsTable[key] = value.getStr()
    except Exception as e:
      error "Error parsing extraParamsJson: ", msg=e.msg

    self.delegate.suggestedRoutes(
      $genUUID(),
      self.sendType,
      self.selectedSenderAccountAddress,
      self.selectedRecipient,
      self.selectedAssetKey,
      amountIn,
      self.selectedToAssetKey,
      amountOut,
      self.fromNetworksRouteModel.getRouteDisabledNetworkChainIds(),
      self.toNetworksRouteModel.getRouteDisabledNetworkChainIds(),
      self.fromNetworksRouteModel.getRouteLockedChainIds(),
      extraParamsTable
    )

  proc updateRoutePreferredChains*(self: View, chainIds: string) {.slot.} =
    self.toNetworksRouteModel.updateRoutePreferredChains(chainIds)

  proc updatedNetworksWithRoutes*(self: View, paths: seq[SuggestedRouteItem], totalFeesInEth: float) =
    self.fromNetworksRouteModel.resetPathData()
    self.toNetworksRouteModel.resetPathData()
    for path in paths:
      let fromChainId = path.getfromNetwork()
      let networkItem = self.delegate.getNetworkItem(fromChainId)
      let hasGas = self.delegate.hasGas(self.selectedSenderAccountAddress, fromChainId, networkItem.nativeCurrencySymbol, totalFeesInEth)
      self.fromNetworksRouteModel.updateFromNetworks(path, hasGas)
      self.toNetworksRouteModel.updateToNetworks(path)

  proc resetStoredProperties*(self: View) {.slot.} =
    self.sendType = transaction_dto.SendType.Transfer
    self.selectedRecipient = ""
    self.fromNetworksRouteModel.reset()
    self.toNetworksRouteModel.reset()
    self.transactionRoutes = newTransactionRoutes()
    self.selectedAssetKey = ""
    self.showUnPreferredChains = false

  proc splitAndFormatAddressPrefix(self: View, text : string, updateInStore: bool): string {.slot.} =
    return self.delegate.splitAndFormatAddressPrefix(text, updateInStore)

  proc getAddressFromFormattedString(self: View, text : string): string {.slot.} =
    var splitWords = plainText(text).split(':')
    for i in countdown(splitWords.len-1, 0):
      if splitWords[i].startsWith("0x"):
        return splitWords[i]
    return ""

  proc getShortChainIds(self: View, chainShortNames : string): string {.slot.} =
    if chainShortNames.isEmptyOrWhitespace():
      return ""
    var preferredChains: seq[int]
    for shortName in chainShortNames.split(':'):
      preferredChains.add(self.delegate.getNetworkChainId(shortName))
    return preferredChains.join(":")

# "Stateless" methods
  proc fetchSuggestedRoutesWithParameters*(self: View,
    uuid: string,
    accountFrom: string,
    accountTo: string,
    amountIn: string,
    amountOut: string,
    token: string,
    toToken: string,
    disabledFromChainIDs: string,
    disabledToChainIDs: string,
    sendType: int,
    lockedInAmounts: string) {.slot.} =
      # Prepare lockedInAmountsTable
      var lockedInAmountsTable = Table[string, string] : initTable[string, string]()
      try:
        for chainId, lockedAmount in parseJson(lockedInAmounts):
          lockedInAmountsTable[chainId] = lockedAmount.getStr
      except:
        discard
      # Resolve the best route
      self.delegate.suggestedRoutes(
        uuid,
        SendType(sendType),
        accountFrom,
        accountTo,
        token,
        amountIn,
        toToken,
        amountOut,
        parseChainIds(disabledFromChainIDs),
        parseChainIds(disabledToChainIDs),
        lockedInAmountsTable)

  proc authenticateAndTransferWithParameters*(self: View, uuid: string, accountFrom: string, accountTo: string, token: string, toToken: string,
    sendTypeInt: int, tokenName: string, tokenIsOwnerToken: bool, rawPaths: string, slippagePercentageString: string) {.slot.} =

    let sendType = SendType(sendTypeInt)

    var slippagePercentage: Option[float]
    if sendType == SendType.Swap:
      if slippagePercentageString.len > 0:
        slippagePercentage = slippagePercentageString.parseFloat().some

    self.delegate.authenticateAndTransferWithPaths(accountFrom, accountTo, token,
      toToken, uuid, sendType, tokenName, tokenIsOwnerToken, rawPaths, slippagePercentage)

  proc transactionSendingComplete*(self: View, txHash: string, success: bool) {.signal.}
  proc sendtransactionSendingCompleteSignal*(self: View, txHash: string, success: bool) =
    self.transactionSendingComplete(txHash, success)
      
  proc setSenderAccount*(self: View, address: string) {.slot.} =
    self.setSelectedSenderAccountAddress(address)
    self.delegate.notifySelectedSenderAccountChanged()

  proc setReceiverAccount*(self: View, address: string) {.slot.} =
    self.setSelectedReceiveAccountAddress(address)