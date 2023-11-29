import NimQml, Tables, sets, json, sequtils, strutils, stint, chronicles
import web3/ethtypes, web3/conversions, stew/byteutils, nimcrypto, json_serialization

import app/core/eventemitter
import app/core/tasks/[qt, threadpool]

import app/global/global_singleton
import backend/ens as status_ens
import backend/backend as status_go_backend
import backend/wallet as status_wallet
import backend/helpers/helpers

import app_service/common/conversion as common_conversion

import utils as ens_utils
import app_service/service/settings/service as settings_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/transaction/service as transaction_service
import app_service/service/network/service as network_service
import app_service/service/token/service as token_service
import app_service/service/eth/utils as status_utils
import app_service/service/eth/dto/coder
import app_service/service/eth/dto/transaction
import dto/ens_username_dto

export ens_username_dto

logScope:
  topics = "ens-service"


const ENS_AVAILABILITY_STATUS_ALREADY_CONNECTED = "already-connected"
const ENS_AVAILABILITY_STATUS_AVAILABLE = "available"
const ENS_AVAILABILITY_STATUS_OWNED = "owned"
const ENS_AVAILABILITY_STATUS_CONNECTED = "connected"
const ENS_AVAILABILITY_STATUS_CONNECTED_DIFFERENT_KEY = "connected-different-key"
const ENS_AVAILABILITY_STATUS_TAKEN = "taken"

include ../../common/json_utils
include async_tasks

type
  EnsUsernameAvailabilityArgs* = ref object of Args
    availabilityStatus*: string

  EnsUsernameDetailsArgs* = ref object of Args
    chainId*: int
    ensUsername*: string
    address*: string
    pubkey*: string
    isStatus*: bool
    expirationTime*: int

  GasPriceArgs* = ref object of Args
    gasPrice*: string

  EnsTransactionArgs* = ref object of Args
    transactionHash*: string
    ensUsername*: string
    transactionType*: string

  EnsTxResultArgs* = ref object of Args
    chainId*: int
    txHash*: string
    error*: string

# Signals which may be emitted by this service:
const SIGNAL_ENS_USERNAME_AVAILABILITY_CHECKED* = "ensUsernameAvailabilityChecked"
const SIGNAL_ENS_USERNAME_DETAILS_FETCHED* = "ensUsernameDetailsFetched"
const SIGNAL_ENS_TRANSACTION_CONFIRMED* = "ensTransactionConfirmed"
const SIGNAL_ENS_TRANSACTION_REVERTED* = "ensTransactionReverted"

QtObject:
  type
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      pendingEnsUsernames*: HashSet[EnsUsernameDto]
      settingsService: settings_service.Service
      walletAccountService: wallet_account_service.Service
      transactionService: transaction_service.Service
      networkService: network_service.Service
      tokenService: token_service.Service

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      settingsService: settings_service.Service,
      walletAccountService: wallet_account_service.Service,
      transactionService: transaction_service.Service,
      networkService: network_service.Service,
      tokenService: token_service.Service
      ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.settingsService = settingsService
    result.walletAccountService = walletAccountService
    result.transactionService = transactionService
    result.networkService = networkService
    result.tokenService = tokenService

  proc getChainId(self: Service): int =
    return self.networkService.getNetworkForEns().chainId

  proc confirmTransaction(self: Service, trxType: string, ensUsername: string, transactionHash: string) =
    let dto = EnsUsernameDto(chainId: self.getChainId(), username: ensUsername)
    let data = EnsTransactionArgs(transactionHash: transactionHash, ensUsername: ensUsername, transactionType: $trxType)
    self.pendingEnsUsernames.excl(dto)
    self.events.emit(SIGNAL_ENS_TRANSACTION_CONFIRMED, data)

  proc revertTransaction(self: Service, trxType: string, ensUsername: string, transactionHash: string) =
    let dto = EnsUsernameDto(chainId: self.getChainId(), username: ensUsername)
    let data = EnsTransactionArgs(transactionHash: transactionHash, ensUsername: ensUsername, transactionType: $trxType)
    self.pendingEnsUsernames.excl(dto)
    self.events.emit(SIGNAL_ENS_TRANSACTION_REVERTED, data)

  proc doConnect(self: Service) =
    self.events.on(PendingTransactionTypeDto.RegisterENS.event) do(e: Args):
      var receivedData = TransactionMinedArgs(e)
      if receivedData.success:
        self.confirmTransaction($PendingTransactionTypeDto.RegisterENS, receivedData.data, receivedData.transactionHash)
      else:
        self.revertTransaction($PendingTransactionTypeDto.RegisterENS, receivedData.data, receivedData.transactionHash)

    self.events.on(PendingTransactionTypeDto.SetPubKey.event) do(e: Args):
      var receivedData = TransactionMinedArgs(e)
      if receivedData.success:
        self.confirmTransaction($PendingTransactionTypeDto.SetPubKey, receivedData.data, receivedData.transactionHash)
      else:
        self.revertTransaction($PendingTransactionTypeDto.SetPubKey, receivedData.data, receivedData.transactionHash)

  proc init*(self: Service) =
    self.doConnect()

    for trx in self.transactionService.getPendingTransactions():
      if trx.typeValue == $PendingTransactionTypeDto.RegisterENS or trx.typeValue == $PendingTransactionTypeDto.SetPubKey:
        let dto = EnsUsernameDto(chainId: trx.chainId, username: trx.additionalData)
        self.pendingEnsUsernames.incl(dto)

  proc getMyPendingEnsUsernames*(self: Service): seq[EnsUsernameDto] =
    for i in self.pendingEnsUsernames.items:
      result.add(i)

  proc getAllMyEnsUsernames*(self: Service, includePending: bool): seq[EnsUsernameDto] =

    var response: JsonNode
    try:
      let rpcResponse = status_ens.getEnsUsernames()
      if rpcResponse.error != nil:
        error "failed to get ens usernames", procName="getAllMyEnsUsernames", error = $rpcResponse.error
        return
      response = rpcResponse.result
    except Exception as e:
      error "error occurred", procName="getAllMyEnsUsernames", msg = e.msg
      return

    if (response.kind != JArray):
      warn "expected response is not a json object", procName="getAllMyEnsUsernames"
      return

    for jsonContact in response:
      result.add(jsonContact.toEnsUsernameDto())

    if (includePending):
      for dto in self.getMyPendingEnsUsernames():
        result.add(dto)

  proc add*(self: Service, chainId: int, username: string): bool =
    try:
      let response = status_ens.add(chainId, username)
      if (not response.error.isNil):
        let msg = response.error.message
        error "error adding ens username ", msg
        return false
    except Exception as e:
      error "error occurred", procName="add", msg = e.msg
      return false
    return true

  proc remove*(self: Service, chainId: int, username: string): bool =
    try:
      let response = status_ens.remove(chainId, username)
      if (not response.error.isNil):
        let msg = response.error.message
        error "error removing ens username ", msg
        return false
    except Exception as e:
      error "error occurred", procName="remove", msg = e.msg
      return false
    return true

  proc onEnsUsernameAvailabilityChecked*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "expected response is not a json object", procName="onEnsUsernameAvailabilityChecked"
      # notify view, this is important
      self.events.emit(SIGNAL_ENS_USERNAME_AVAILABILITY_CHECKED, EnsUsernameAvailabilityArgs())
      return

    var availablilityStatus: string
    discard responseObj.getProp("availability", availablilityStatus)
    let data = EnsUsernameAvailabilityArgs(availabilityStatus: availablilityStatus)
    self.events.emit(SIGNAL_ENS_USERNAME_AVAILABILITY_CHECKED, data)

  proc formatUsername(self: Service, username: string, isStatus: bool): string =
    result = username
    if isStatus:
      result = result & ens_utils.STATUS_DOMAIN

  proc checkEnsUsernameAvailability*(self: Service, ensUsername: string, isStatus: bool) =
    let registeredEnsUsernames = self.getAllMyEnsUsernames(true)
    let dto = EnsUsernameDto(chainId: self.getChainId(),
                             username: self.formatUsername(ensUsername, isStatus))
    var availability = ""
    if registeredEnsUsernames.find(dto) >= 0:
      let data = EnsUsernameAvailabilityArgs(availabilityStatus: ENS_AVAILABILITY_STATUS_ALREADY_CONNECTED)
      self.events.emit(SIGNAL_ENS_USERNAME_AVAILABILITY_CHECKED, data)
    else:
      let arg = CheckEnsAvailabilityTaskArg(
        tptr: cast[ByteAddress](checkEnsAvailabilityTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onEnsUsernameAvailabilityChecked",
        ensUsername: ensUsername,
        chainId: self.getChainId(),
        isStatus: isStatus,
        myPublicKey: self.settingsService.getPublicKey(),
        myWalletAddress: self.walletAccountService.getWalletAccount(0).address
      )
      self.threadpool.start(arg)

  proc onEnsUsernameDetailsFetched*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "expected response is not a json object", procName="onEnsUsernameDetailsFetched"
      # notify view, this is important
      self.events.emit(SIGNAL_ENS_USERNAME_DETAILS_FETCHED, EnsUsernameDetailsArgs())
      return

    var data = EnsUsernameDetailsArgs()
    discard responseObj.getProp("chainId", data.chainId)
    discard responseObj.getProp("ensUsername", data.ensUsername)
    discard responseObj.getProp("address", data.address)
    discard responseObj.getProp("pubkey", data.pubkey)
    discard responseObj.getProp("isStatus", data.isStatus)
    discard responseObj.getProp("expirationTime", data.expirationTime)
    self.events.emit(SIGNAL_ENS_USERNAME_DETAILS_FETCHED, data)

  proc fetchDetailsForEnsUsername*(self: Service, chainId: int, ensUsername: string) =
    var isStatus = false
    var username = ensUsername
    if ensUsername.endsWith(ens_utils.STATUS_DOMAIN):
      username = ensUsername.replace(ens_utils.STATUS_DOMAIN, "")
      isStatus = true

    let arg = EnsUsernamDetailsTaskArg(
      tptr: cast[ByteAddress](ensUsernameDetailsTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onEnsUsernameDetailsFetched",
      ensUsername: username,
      chainId: chainId,
      isStatus: isStatus
    )
    self.threadpool.start(arg)

  proc extractCoordinates(self: Service, pubkey: string):tuple[x: string, y:string] =
    result = ("0x" & pubkey[4..67], "0x" & pubkey[68..131])

  proc setPubKeyGasEstimate*(self: Service, chainId: int, ensUsername: string, address: string): int =
    try:
      let txData = ens_utils.buildTransaction(parseAddress(address), 0.u256)
      let resp = status_ens.setPubKeyEstimate(chainId, %txData, ensUsername,
        singletonInstance.userProfile.getPubKey())
      result = resp.result.getInt
    except Exception as e:
      result = 80000
      error "error occurred", procName="setPubKeyGasEstimate", msg = e.msg

  proc releaseEnsEstimate*(self: Service, chainId: int, ensUsername: string, address: string): int =
    try:
      let txData = ens_utils.buildTransaction(parseAddress(address), 0.u256)
      var userNameNoDomain = ensUsername
      if ensUsername.endsWith(ens_utils.STATUS_DOMAIN):
        userNameNoDomain = ensUsername.replace(ens_utils.STATUS_DOMAIN, "")

      let resp = status_ens.releaseEstimate(chainId, %txData, userNameNoDomain)
      result = resp.result.getInt
    except Exception as e:
      error "error occurred", procName="releaseEnsEstimate", msg = e.msg
      result = 100000

  proc getEnsRegisteredAddress*(self: Service): string =
    return status_ens.getRegistrarAddress(self.getChainId()).result.getStr

  proc registerENSGasEstimate*(self: Service, chainId: int, ensUsername: string, address: string): int =
    try:
      let txData = ens_utils.buildTransaction(parseAddress(address), 0.u256)
      let resp = status_ens.registerEstimate(chainId, %txData, ensUsername,
        singletonInstance.userProfile.getPubKey())
      result = resp.result.getInt
    except Exception as e:
      result = 380000
      error "error occurred", procName="registerENSGasEstimate", msg = e.msg

  proc getStatusToken*(self: Service): TokenDto =
    let networkDto = self.networkService.getNetworkForEns()
    return self.tokenService.findTokenBySymbol(networkDto.chainId, networkDto.sntSymbol())

  proc getSNTBalance*(self: Service): string =
    let token = self.getStatusToken()
    let account = self.walletAccountService.getWalletAccount(0).address

    let info = getTokenBalanceForAccount(self.getChainId(), account, token.symbol)
    if info.isNone:
      return "0"
    return ens_utils.hex2Token(info.get().rawBalance.toString(16), token.decimals)

  proc resourceUrl*(self: Service, username: string): (string, string, string) =
    try:
      let response = status_ens.resourceURL(self.getChainId(), username)
      return (response.result{"Scheme"}.getStr, response.result{"Host"}.getStr, response.result{"Path"}.getStr)
    except Exception as e:
      error "Error getting ENS resourceUrl", username=username, exception=e.msg
      raise

  proc prepareEnsTx*(self: Service, txType: PendingTransactionTypeDto, chainId: int, ensUsername: string, address: string,
    gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool): JsonNode =
    try:
      var prepareTxResponse: RpcResponse[JsonNode]
      let txData = ens_utils.buildTransaction(parseAddress(address), 0.u256, gas, gasPrice, eip1559Enabled,
        maxPriorityFeePerGas, maxFeePerGas)
      if txType == PendingTransactionTypeDto.SetPubKey:
        prepareTxResponse = status_ens.prepareTxForSetPubKey(chainId, %txData, ensUsername.addDomain(),
          singletonInstance.userProfile.getPubKey())
      elif txType == PendingTransactionTypeDto.RegisterENS:
        prepareTxResponse = status_ens.prepareTxForRegisterEnsUsername(chainId, %txData, ensUsername,
          singletonInstance.userProfile.getPubKey())
      elif txType == PendingTransactionTypeDto.ReleaseENS:
        var userNameNoDomain = ensUsername
        if ensUsername.endsWith(ens_utils.STATUS_DOMAIN):
          userNameNoDomain = ensUsername.replace(ens_utils.STATUS_DOMAIN, "")
        prepareTxResponse = status_ens.prepareTxForReleaseEnsUsername(chainId, %txData, userNameNoDomain)
      else:
        error "Unknown action", procName="prepareEnsTx"

      if not prepareTxResponse.error.isNil:
        error "error occurred", procName="prepareEnsTx", msg = prepareTxResponse.error.message
        return

      prepareTxResponse.result["gas"] = %* (if gas.isEmptyOrWhitespace: Quantity.none else: Quantity(cast[uint64](parseFloat(gas).toUInt64)).some)
      if eip1559Enabled:
        let maxPriorityFeePerGasFinal = if maxPriorityFeePerGas.isEmptyOrWhitespace: Uint256.none else: gwei2Wei(parseFloat(maxPriorityFeePerGas)).some
        let maxFeePerGasFinal = if maxFeePerGas.isEmptyOrWhitespace: Uint256.none else: gwei2Wei(parseFloat(maxFeePerGas)).some
        prepareTxResponse.result["maxPriorityFeePerGas"] = %* ("0x" & maxPriorityFeePerGasFinal.unsafeGet.toHex)
        prepareTxResponse.result["maxFeePerGas"] = %* ("0x" & maxFeePerGasFinal.unsafeGet.toHex)
      else:
        let gasPriceFinal = if gasPrice.isEmptyOrWhitespace: int.none else: gwei2Wei(parseFloat(gasPrice)).truncate(int).some
        prepareTxResponse.result["gasPrice"] = %* ("0x" & gasPriceFinal.unsafeGet.toHex.stripLeadingZeros)

      var buildTxResponse: JsonNode
      let err = status_wallet.buildTransaction(buildTxResponse, chainId, $prepareTxResponse.result)
      if err.len > 0:
        error "error occurred", procName="prepareEnsTx", msg = err
        return

      return buildTxResponse
    except Exception as e:
      error "error occurred", procName="prepareEnsTx", msg = e.msg

  proc signEnsTxLocally*(self: Service, data, account, hashedPasssword: string): string =
    try:
      var response: JsonNode
      let err = status_wallet.signMessage(response, data, account, hashedPasssword)
      if err.len > 0 or response.isNil:
        error "error occurred", procName="signEnsTxLocally", msg = err
        return
      return response.getStr()
    except Exception as e:
      error "error occurred", procName="signEnsTxLocally", msg = e.msg

  proc sendEnsTxWithSignatureAndWatch*(self: Service, txType: PendingTransactionTypeDto, chainId: int,
    txData: JsonNode, ensUsername: string, signature: string): EnsTxResultArgs =
    result = EnsTxResultArgs(chainId: chainId)
    try:
      if txData.isNil:
        result.error = "txData is nil"
        error "error occurred", procName="sendEnsTxWithSignatureAndWatch", msg = result.error
        return
      if not txData.hasKey("from") or txData["from"].getStr().len == 0:
        result.error = "from address is empty"
        error "error occurred", procName="sendEnsTxWithSignatureAndWatch", msg = result.error
        return
      if not txData.hasKey("to") or txData["to"].getStr().len == 0:
        result.error = "to address is empty"
        error "error occurred", procName="sendEnsTxWithSignatureAndWatch", msg = result.error
        return
      if txType != PendingTransactionTypeDto.SetPubKey and
        txType != PendingTransactionTypeDto.RegisterENS and
        txType != PendingTransactionTypeDto.ReleaseENS:
          result.error = "invalid tx type"
          error "error occurred", procName="sendEnsTxWithSignatureAndWatch", msg = result.error
          return

      var finalSignature = signature
      if finalSignature.startsWith("0x"):
        finalSignature = finalSignature[2..^1]

      var txResponse: JsonNode
      let err = status_wallet.sendTransactionWithSignature(txResponse, chainId, $txType, $txData, finalSignature)
      if err.len > 0 or txResponse.isNil:
        result.error = err
        error "error occurred", procName="sendEnsTxWithSignatureAndWatch", msg = result.error
        return

      let
        transactionHash = txResponse.getStr()
        fromAddress = txData["from"].getStr()
        toAddress = txData["to"].getStr()

      if txType == PendingTransactionTypeDto.SetPubKey:
        let usernameWithDomain = ensUsername.addDomain()
        if not self.add(chainId, usernameWithDomain):
          result.error = "failed to add ens username"
          error "error occurred", procName="sendEnsTxWithSignatureAndWatch", msg = result.error
          return
        let resolverAddress = status_ens.resolver(chainId, usernameWithDomain).result.getStr
        self.transactionService.watchTransaction(transactionHash, fromAddress, resolverAddress, $txType,
          ensUsername, chainId)
        let dto = EnsUsernameDto(chainId: chainId, username: ensUsername)
        self.pendingEnsUsernames.incl(dto)
      elif txType == PendingTransactionTypeDto.RegisterENS:
        let sntContract = self.getStatusToken()
        let ensUsernameFinal = self.formatUsername(ensUsername, true)
        if not self.add(chainId, ensUsernameFinal):
          result.error = "failed to add ens username"
          error "error occurred", procName="sendEnsTxWithSignatureAndWatch", msg = result.error
          return
        self.transactionService.watchTransaction(transactionHash, fromAddress, $sntContract.address, $txType,
          ensUsernameFinal, chainId)
        let dto = EnsUsernameDto(chainId: chainId, username: ensUsernameFinal)
        self.pendingEnsUsernames.incl(dto)
      elif txType == PendingTransactionTypeDto.ReleaseENS:
        let ensUsernameFinal = self.formatUsername(ensUsername, true)
        if not self.remove(chainId, ensUsernameFinal):
          result.error = "failed to add ens username"
          error "error occurred", procName="sendEnsTxWithSignatureAndWatch", msg = result.error
          return
        let ensUsernamesAddress = self.getEnsRegisteredAddress()
        self.transactionService.watchTransaction(transactionHash, fromAddress, ensUsernamesAddress, $txType, ensUsername, chainId)
        let dto = EnsUsernameDto(chainId: chainId, username: ensUsername)
        self.pendingEnsUsernames.excl(dto)

      result.txHash = transactionHash
    except Exception as e:
      result.error = e.msg
      error "error occurred", procName="sendEnsTxWithSignatureAndWatch", msg = result.error