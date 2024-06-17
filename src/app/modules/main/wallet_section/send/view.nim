import NimQml, sequtils, strutils, stint

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

  proc parseAmount(amount: string): Uint256 =
    var parsedAmount = stint.u256(0)
    try:
      parsedAmount = amount.parse(Uint256)
    except Exception as e:
      discard
    return parsedAmount
  
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

  proc suggestedRoutes*(self: View, amount: string): string {.slot.} =
    var parsedAmount = stint.u256(0)
    try:
      parsedAmount = amount.parse(Uint256)
    except Exception as e:
      discard

    self.delegate.suggestedRoutes(self.selectedSenderAccountAddress, self.selectedRecipient,
      parsedAmount, self.selectedAssetKey, self.selectedToAssetKey, self.fromNetworksModel.getRouteDisabledNetworkChainIds(),
      self.toNetworksModel.getRouteDisabledNetworkChainIds(), self.toNetworksModel.getRoutePreferredNetworkChainIds(),
      self.sendType, self.fromNetworksModel.getRouteLockedChainIds())

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
  proc fetchSuggestedRoutesWithParameters*(self: View, accountFrom: string, accountTo: string, amount: string, token: string, toToken: string,
    disabledFromChainIDs: string, disabledToChainIDs: string, preferredChainIDs: string, sendType: int, lockedInAmounts: string) {.slot.} =
    self.delegate.suggestedRoutes(accountFrom, accountTo,
      parseAmount(amount), token, toToken, 
      parseChainIds(disabledFromChainIDs), parseChainIds(disabledToChainIDs), parseChainIds(preferredChainIDs),
      SendType(sendType), lockedInAmounts)
  
  proc authenticateAndTransferWithParameters*(self: View, uuid: string, accountFrom: string, accountTo: string, token: string, toToken: string,
    sendType: int, tokenName: string, tokenIsOwnerToken: bool, rawPaths: string) {.slot.} =
    self.delegate.authenticateAndTransferWithPaths(accountFrom, accountTo, token,
      toToken, uuid, SendType(sendType), tokenName, tokenIsOwnerToken, rawPaths)
      
  proc switchSenderAccount*(self: View, address: string) {.slot.} =
    self.setSelectedSenderAccountAddress(address)
    self.delegate.notifySelectedSenderAccountChanged()

  proc switchReceiveAccount*(self: View, address: string) {.slot.} =
    self.setSelectedReceiveAccountAddress(address)
