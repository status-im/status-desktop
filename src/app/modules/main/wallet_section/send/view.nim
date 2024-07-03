import NimQml, Tables, json, sequtils, strutils, stint, options, chronicles
import uuids

import ./io_interface, ./network_model, ./network_item, ./suggested_route_item, ./transaction_routes
import app/modules/shared_models/collectibles_model as collectibles
import app/modules/shared_models/collectibles_nested_model as nested_collectibles
import app_service/service/transaction/dto as transaction_dto

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      # list of collectibles owned by the selected sender account
      collectiblesModel: collectibles.Model
      nestedCollectiblesModel: nested_collectibles.Model
      # for send modal
      fromNetworksModel: NetworkModel
      toNetworksModel: NetworkModel
      transactionRoutes: TransactionRoutes
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
    self.fromNetworksModel.delete
    self.toNetworksModel.delete
    self.transactionRoutes.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.fromNetworksModel = newNetworkModel()
    result.toNetworksModel = newNetworkModel()
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

  proc fromNetworksModelChanged*(self: View) {.signal.}
  proc getFromNetworksModel(self: View): QVariant {.slot.} =
    return newQVariant(self.fromNetworksModel)
  QtProperty[QVariant] fromNetworksModel:
    read = getFromNetworksModel
    notify = fromNetworksModelChanged

  proc toNetworksModelChanged*(self: View) {.signal.}
  proc getToNetworksModel(self: View): QVariant {.slot.} =
    return newQVariant(self.toNetworksModel)
  QtProperty[QVariant] toNetworksModel:
    read = getToNetworksModel
    notify = toNetworksModelChanged

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
      self.toNetworksModel.disableRouteUnpreferredChains()
    else:
      self.toNetworksModel.enableRouteUnpreferredChains()

  proc updateNetworksTokenBalance(self: View) =
    for chainId in self.toNetworksModel.getAllNetworksChainIds():
      self.fromNetworksModel.updateTokenBalanceForSymbol(chainId, self.delegate.getTokenBalance(self.selectedSenderAccountAddress, chainId, self.selectedAssetKey))
      self.toNetworksModel.updateTokenBalanceForSymbol(chainId, self.delegate.getTokenBalance(self.selectedSenderAccountAddress, chainId, self.selectedAssetKey))

  proc setNetworkItems*(self: View, fromNetworks: seq[NetworkItem], toNetworks: seq[NetworkItem]) =
    self.fromNetworksModel.setItems(fromNetworks)
    self.toNetworksModel.setItems(toNetworks)

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

  proc suggestedRoutesReady*(self: View, suggestedRoutes: QVariant) {.signal.}
  proc setTransactionRoute*(self: View, routes: TransactionRoutes) =
    self.transactionRoutes = routes
    self.suggestedRoutesReady(newQVariant(self.transactionRoutes))

  proc suggestedRoutes*(self: View, amountIn: string, amountOut: string, extraParamsJson: string) {.slot.} =
    var extraParamsTable: Table[string, string]
    try:
      if extraParamsJson.len > 0:
        for key, value in parseJson(extraParamsJson):
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
      self.fromNetworksModel.getRouteDisabledNetworkChainIds(),
      self.toNetworksModel.getRouteDisabledNetworkChainIds(),
      self.fromNetworksModel.getRouteLockedChainIds(),
      extraParamsTable
    )

  proc updateRoutePreferredChains*(self: View, chainIds: string) {.slot.} =
    self.toNetworksModel.updateRoutePreferredChains(chainIds)

  proc updatedNetworksWithRoutes*(self: View, paths: seq[SuggestedRouteItem], totalFeesInEth: float) =
    self.fromNetworksModel.resetPathData()
    self.toNetworksModel.resetPathData()
    for path in paths:
      let fromChainId = path.getfromNetwork()
      let hasGas = self.delegate.hasGas(self.selectedSenderAccountAddress, fromChainId, self.fromNetworksModel.getNetworkNativeGasSymbol(fromChainId), totalFeesInEth)
      self.fromNetworksModel.updateFromNetworks(path, hasGas)
      self.toNetworksModel.updateToNetworks(path)

  proc resetStoredProperties*(self: View) {.slot.} =
    self.sendType = transaction_dto.SendType.Transfer
    self.selectedRecipient = ""
    self.fromNetworksModel.reset()
    self.toNetworksModel.reset()
    self.transactionRoutes = newTransactionRoutes()
    self.selectedAssetKey = ""
    self.showUnPreferredChains = false

  proc getLayer1NetworkChainId*(self: View): string =
    return $self.fromNetworksModel.getLayer1Network()

  proc getNetworkColor*(self: View, shortName : string): string =
    return self.fromNetworksModel.getNetworkColor(shortName)

  proc getNetworkChainId*(self: View, shortName : string): int =
    return self.fromNetworksModel.getNetworkChainId(shortName)

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
      preferredChains.add(self.fromNetworksModel.getNetworkChainId(shortName))
    return preferredChains.join(":")

  proc getIconUrl*(self: View, chainId: int): string {.slot.} =
    return self.fromNetworksModel.getIconUrl(chainId)

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