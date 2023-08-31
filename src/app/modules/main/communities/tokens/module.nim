import NimQml, json, stint, strutils, chronicles

import ../../../../../app_service/service/community_tokens/service as community_tokens_service
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/network/service as networks_service
import ../../../../../app_service/service/community/service as community_service
import ../../../../../app_service/service/community/dto/community
import ../../../../../app_service/service/accounts/utils as utl
import ../../../../../app_service/common/conversion
import ../../../../../app_service/common/types
import ../../../../core/eventemitter
import ../../../../global/global_singleton
import ../../../shared_models/currency_amount
import ../io_interface as parent_interface
import ./io_interface, ./view , ./controller

export io_interface

type
  ContractAction {.pure.} = enum
    Unknown = 0
    Deploy = 1
    Airdrop = 2
    SelfDestruct = 3
    Burn = 4
    DeployOwnerToken = 5

type
  Module*  = ref object of io_interface.AccessInterface
    parent: parent_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    tempTokenAndAmountList: seq[CommunityTokenAndAmount]
    tempWalletAndAmountList: seq[WalletAndAmount]
    tempAddressFrom: string
    tempCommunityId: string
    tempChainId: int
    tempContractAddress: string
    tempDeploymentParams: DeploymentParameters
    tempTokenMetadata: CommunityTokensMetadataDto
    tempTokenImageCropInfoJson: string
    tempWalletAddresses: seq[string]
    tempContractAction: ContractAction
    tempContractUniqueKey: string
    tempAmount: Uint256
    tempOwnerDeploymentParams: DeploymentParameters
    tempMasterDeploymentParams: DeploymentParameters
    tempOwnerTokenMetadata: CommunityTokensMetadataDto
    tempMasterTokenMetadata: CommunityTokensMetadataDto

proc newCommunityTokensModule*(
    parent: parent_interface.AccessInterface,
    events: EventEmitter,
    communityTokensService: community_tokens_service.Service,
    transactionService: transaction_service.Service,
    networksService: networks_service.Service,
    communityService: community_service.Service): Module =
  result = Module()
  result.parent = parent
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newCommunityTokensController(result, events, communityTokensService, transactionService, networksService, communityService)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method resetTempValues(self:Module) =
  self.tempAddressFrom = ""
  self.tempCommunityId = ""
  self.tempDeploymentParams = DeploymentParameters()
  self.tempTokenMetadata = CommunityTokensMetadataDto()
  self.tempTokenImageCropInfoJson = ""
  self.tempChainId = 0
  self.tempContractAddress = ""
  self.tempWalletAddresses = @[]
  self.tempContractAction = ContractAction.Unknown
  self.tempTokenAndAmountList = @[]
  self.tempWalletAndAmountList = @[]
  self.tempContractUniqueKey = ""

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("communityTokensModule", self.viewVariant)
  self.controller.init()
  self.view.load()

proc authenticate(self: Module) =
  if singletonInstance.userProfile.getIsKeycardUser():
    let keyUid = singletonInstance.userProfile.getKeyUid()
    self.controller.authenticateUser(keyUid)
  else:
    self.controller.authenticateUser()

proc getTokenAndAmountList(self: Module, communityId: string, tokensJsonString: string): seq[CommunityTokenAndAmount] =
  try:
    let tokensJson = tokensJsonString.parseJson
    for token in tokensJson:
      let contractUniqueKey = token["contractUniqueKey"].getStr
      let tokenDto = self.controller.findContractByUniqueId(contractUniqueKey)
      let amountStr = token["amount"].getStr
      if tokenDto.tokenType == TokenType.Unknown:
        error "Can't find token for community", contractUniqueKey=contractUniqueKey
        return @[]
      result.add(CommunityTokenAndAmount(communityToken: tokenDto, amount: amountStr.parse(Uint256)))
  except Exception as e:
    error "Error getTokenAndAmountList", msg = e.msg

method airdropTokens*(self: Module, communityId: string, tokensJsonString: string, walletsJsonString: string, addressFrom: string) =
  self.tempTokenAndAmountList = self.getTokenAndAmountList(communityId, tokensJsonString)
  if len(self.tempTokenAndAmountList) == 0:
    return
  self.tempWalletAddresses = walletsJsonString.parseJson.to(seq[string])
  self.tempCommunityId = communityId
  self.tempAddressFrom = addressFrom
  self.tempContractAction = ContractAction.Airdrop
  self.authenticate()

method computeAirdropFee*(self: Module, communityId: string, tokensJsonString: string, walletsJsonString: string, addressFrom: string, requestId: string) =
  let tokenAndAmountList = self.getTokenAndAmountList(communityId, tokensJsonString)
  if len(tokenAndAmountList) == 0:
    return
  self.controller.computeAirdropFee(tokenAndAmountList, walletsJsonString.parseJson.to(seq[string]), addressFrom, requestId)

proc getWalletAndAmountListFromJson(self: Module, collectiblesToBurnJsonString: string): seq[WalletAndAmount] =
  let collectiblesToBurnJson = collectiblesToBurnJsonString.parseJson
  for collectibleToBurn in collectiblesToBurnJson:
    let walletAddress = collectibleToBurn["walletAddress"].getStr
    let amount = collectibleToBurn["amount"].getInt
    result.add(WalletAndAmount(walletAddress: walletAddress, amount: amount))

method selfDestructCollectibles*(self: Module, communityId: string, collectiblesToBurnJsonString: string, contractUniqueKey: string, addressFrom: string) =
  self.tempWalletAndAmountList = self.getWalletAndAmountListFromJson(collectiblesToBurnJsonString)
  self.tempCommunityId = communityId
  self.tempContractUniqueKey = contractUniqueKey
  self.tempAddressFrom = addressFrom
  self.tempContractAction = ContractAction.SelfDestruct
  self.authenticate()

method burnTokens*(self: Module, communityId: string, contractUniqueKey: string, amount: string, addressFrom: string) =
  self.tempCommunityId = communityId
  self.tempContractUniqueKey = contractUniqueKey
  self.tempAmount = amount.parse(Uint256)
  self.tempAddressFrom = addressFrom
  self.tempContractAction = ContractAction.Burn
  self.authenticate()

method deployCollectibles*(self: Module, communityId: string, fromAddress: string, name: string, symbol: string, description: string,
                           supply: string, infiniteSupply: bool, transferable: bool, selfDestruct: bool, chainId: int, imageCropInfoJson: string) =
  let ownerToken = self.controller.getOwnerToken(communityId)
  let masterToken = self.controller.getTokenMasterToken(communityId)

  if not (ownerToken.address != "" and ownerToken.deployState == DeployState.Deployed and masterToken.address != "" and masterToken.deployState == DeployState.Deployed):
      error "Owner token and master token not deployed"
      return

  self.tempAddressFrom = fromAddress
  self.tempCommunityId = communityId
  self.tempChainId = chainId
  self.tempDeploymentParams.name = name
  self.tempDeploymentParams.symbol = symbol
  self.tempDeploymentParams.supply = supply.parse(Uint256)
  self.tempDeploymentParams.infiniteSupply = infiniteSupply
  self.tempDeploymentParams.transferable = transferable
  self.tempDeploymentParams.remoteSelfDestruct = selfDestruct
  self.tempDeploymentParams.tokenUri = utl.changeCommunityKeyCompression(communityId) & "/"
  self.tempDeploymentParams.ownerTokenAddress = ownerToken.address
  self.tempDeploymentParams.masterTokenAddress = masterToken.address
  self.tempTokenMetadata.tokenType = TokenType.ERC721
  self.tempTokenMetadata.description = description
  self.tempTokenImageCropInfoJson = imageCropInfoJson
  self.tempContractAction = ContractAction.Deploy
  self.authenticate()

method deployOwnerToken*(self: Module, communityId: string, fromAddress: string, ownerName: string, ownerSymbol: string, ownerDescription: string,
                        masterName: string, masterSymbol: string, masterDescription: string, chainId: int, imageCropInfoJson: string) =
  let ownerToken = self.controller.getOwnerToken(communityId)
  let masterToken = self.controller.getTokenMasterToken(communityId)

  if ownerToken.address != "" and ownerToken.deployState != DeployState.Failed and masterToken.address != "" and masterToken.deployState == DeployState.Failed:
      error "Owner token and master token are deployed or pending"
      return

  self.tempAddressFrom = fromAddress
  self.tempCommunityId = communityId
  self.tempChainId = chainId
  let communityDto = self.controller.getCommunityById(communityId)
  let commName = communityDto.name
  let commNameShort = try: commName[0 .. 2].toUpper except: commName.toUpper
  self.tempOwnerDeploymentParams = DeploymentParameters(name: "Owner-" & commName, symbol: "OWN" & commNameShort, supply: stint.u256("1"), infiniteSupply: false, transferable: true, remoteSelfDestruct: false, tokenUri: utl.changeCommunityKeyCompression(communityId) & "/")
  self.tempMasterDeploymentParams = DeploymentParameters(name: "TMaster-" & commName, symbol: "TM" & commNameShort, infiniteSupply: true, transferable: false, remoteSelfDestruct: true, tokenUri: utl.changeCommunityKeyCompression(communityId) & "/")
  self.tempOwnerTokenMetadata.description = ownerDescription
  self.tempOwnerTokenMetadata.tokenType = TokenType.ERC721
  self.tempMasterTokenMetadata.description = masterDescription
  self.tempMasterTokenMetadata.tokenType = TokenType.ERC721
  self.tempTokenImageCropInfoJson = imageCropInfoJson
  self.tempContractAction = ContractAction.DeployOwnerToken
  self.authenticate()

method deployAssets*(self: Module, communityId: string, fromAddress: string, name: string, symbol: string, description: string, supply: string, infiniteSupply: bool, decimals: int,
                     chainId: int, imageCropInfoJson: string) =
  self.tempAddressFrom = fromAddress
  self.tempCommunityId = communityId
  self.tempChainId = chainId
  self.tempDeploymentParams.name = name
  self.tempDeploymentParams.symbol = symbol
  self.tempDeploymentParams.supply = supply.parse(Uint256)
  self.tempDeploymentParams.infiniteSupply = infiniteSupply
  self.tempDeploymentParams.decimals = decimals
  self.tempDeploymentParams.tokenUri = utl.changeCommunityKeyCompression(communityId) & "/"
  self.tempTokenMetadata.tokenType = TokenType.ERC20
  self.tempTokenMetadata.description = description
  self.tempTokenImageCropInfoJson = imageCropInfoJson
  self.tempContractAction = ContractAction.Deploy
  self.authenticate()

method removeCommunityToken*(self: Module, communityId: string, chainId: int, address: string) =
  self.controller.removeCommunityToken(communityId, chainId, address)

method onUserAuthenticated*(self: Module, password: string) =
  defer: self.resetTempValues()
  if password.len == 0:
    discard
    #TODO signalize somehow
  else:
    if self.tempContractAction == ContractAction.Deploy:
      self.controller.deployContract(self.tempCommunityId, self.tempAddressFrom, password, self.tempDeploymentParams, self.tempTokenMetadata, self.tempTokenImageCropInfoJson, self.tempChainId)
    elif self.tempContractAction == ContractAction.Airdrop:
      self.controller.airdropTokens(self.tempCommunityId, password, self.tempTokenAndAmountList, self.tempWalletAddresses, self.tempAddressFrom)
    elif self.tempContractAction == ContractAction.SelfDestruct:
      self.controller.selfDestructCollectibles(self.tempCommunityId, password, self.tempWalletAndAmountList, self.tempContractUniqueKey, self.tempAddressFrom)
    elif self.tempContractAction == ContractAction.Burn:
      self.controller.burnTokens(self.tempCommunityId, password, self.tempContractUniqueKey, self.tempAmount, self.tempAddressFrom)
    elif self.tempContractAction == ContractAction.DeployOwnerToken:
      self.controller.deployOwnerContracts(self.tempCommunityId, self.tempAddressFrom, password,
                self.tempOwnerDeploymentParams, self.tempOwnerTokenMetadata,
                self.tempMasterDeploymentParams, self.tempMasterTokenMetadata,
                self.tempTokenImageCropInfoJson, self.tempChainId)

method onDeployFeeComputed*(self: Module, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: ComputeFeeErrorCode, responseId: string) =
  self.view.updateDeployFee(ethCurrency, fiatCurrency, errorCode.int, responseId)

method onSelfDestructFeeComputed*(self: Module, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: ComputeFeeErrorCode, responseId: string) =
  self.view.updateSelfDestructFee(ethCurrency, fiatCurrency, errorCode.int, responseId)

method onAirdropFeesComputed*(self: Module, args: AirdropFeesArgs) =
  self.view.updateAirdropFees(%args)

method onBurnFeeComputed*(self: Module, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: ComputeFeeErrorCode, responseId: string) =
  self.view.updateBurnFee(ethCurrency, fiatCurrency, errorCode.int, responseId)

method computeDeployFee*(self: Module, chainId: int, accountAddress: string, tokenType: TokenType, isOwnerDeployment: bool, requestId: string) =
  if isOwnerDeployment:
    self.controller.computeDeployOwnerContractsFee(chainId, accountAddress, requestId)
  else:
    self.controller.computeDeployFee(chainId, accountAddress, tokenType, requestId)

method computeSelfDestructFee*(self: Module, collectiblesToBurnJsonString: string, contractUniqueKey: string, addressFrom: string, requestId: string) =
  let walletAndAmountList = self.getWalletAndAmountListFromJson(collectiblesToBurnJsonString)
  self.controller.computeSelfDestructFee(walletAndAmountList, contractUniqueKey, addressFrom, requestId)

method computeBurnFee*(self: Module, contractUniqueKey: string, amount: string, addressFrom: string, requestId: string) =
  self.controller.computeBurnFee(contractUniqueKey, amount.parse(Uint256), addressFrom, requestId)

proc createUrl(self: Module, chainId: int, transactionHash: string): string =
  let network = self.controller.getNetwork(chainId)
  result = if network != nil: network.blockExplorerURL & "/tx/" & transactionHash else: ""

proc getChainName(self: Module, chainId: int): string =
  let network = self.controller.getNetwork(chainId)
  result = if network != nil: network.chainName else: ""

method onCommunityTokenDeployStateChanged*(self: Module, communityId: string, chainId: int, transactionHash: string, deployState: DeployState) =
  let url = self.createUrl(chainId, transactionHash)
  self.view.emitDeploymentStateChanged(communityId, deployState.int, url)

method onOwnerTokenDeployStateChanged*(self: Module, communityId: string, chainId: int, transactionHash: string, deployState: DeployState) =
  let url = self.createUrl(chainId, transactionHash)
  self.view.emitOwnerTokenDeploymentStateChanged(communityId, deployState.int, url)

method onOwnerTokenDeployStarted*(self: Module, communityId: string, chainId: int, transactionHash: string) =
  let url = self.createUrl(chainId, transactionHash)
  self.view.emitOwnerTokenDeploymentStarted(communityId, url)

method onRemoteDestructStateChanged*(self: Module, communityId: string, tokenName: string, chainId: int, transactionHash: string, status: ContractTransactionStatus) =
  let url = self.createUrl(chainId, transactionHash)
  self.view.emitRemoteDestructStateChanged(communityId, tokenName, status.int, url)

method onBurnStateChanged*(self: Module, communityId: string, tokenName: string, chainId: int, transactionHash: string, status: ContractTransactionStatus) =
  let url = self.createUrl(chainId, transactionHash)
  self.view.emitBurnStateChanged(communityId, tokenName, status.int, url)

method onAirdropStateChanged*(self: Module, communityId: string, tokenName: string, chainId: int, transactionHash: string, status: ContractTransactionStatus) =
  let url = self.createUrl(chainId, transactionHash)
  let chainName = self.getChainName(chainId)
  self.view.emitAirdropStateChanged(communityId, tokenName, chainName, status.int, url)
