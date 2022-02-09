import NimQml, Tables, sets, json, sequtils, strutils, strformat, chronicles
import web3/conversions
import web3/[conversions, ethtypes], stint
import web3/ethtypes

import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import ../../../app/global/global_singleton
import ../../../backend/eth as status_eth
import ../../../backend/ens as status_ens
import ../network/types as network_types

import ../../common/conversion as common_conversion
import utils as ens_utils
import ../settings/service_interface as settings_service
import ../wallet_account/service_interface as wallet_account_service
import ../transaction/service as transaction_service
import ../eth/service_interface as eth_service
import ../network/service_interface as network_service
import ../token/service as token_service


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
    revertReason*: string

# Signals which may be emitted by this service:
const SIGNAL_ENS_USERNAME_AVAILABILITY_CHECKED* = "ensUsernameAvailabilityChecked"
const SIGNAL_ENS_USERNAME_DETAILS_FETCHED* = "ensUsernameDetailsFetched"
const SIGNAL_GAS_PRICE_FETCHED* = "gasPriceFetched"
const SIGNAL_ENS_TRANSACTION_CONFIRMED* = "ensTransactionConfirmed"
const SIGNAL_ENS_TRANSACTION_REVERTED* = "ensTransactionReverted"

QtObject:
  type
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      pendingEnsUsernames*: HashSet[string]
      settingsService: settings_service.ServiceInterface
      walletAccountService: wallet_account_service.ServiceInterface
      transactionService: transaction_service.Service
      ethService: eth_service.ServiceInterface
      networkService: network_service.ServiceInterface
      tokenService: token_service.Service

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      settingsService: settings_service.ServiceInterface,
      walletAccountService: wallet_account_service.ServiceInterface,
      transactionService: transaction_service.Service,
      ethService: eth_service.ServiceInterface,
      networkService: network_service.ServiceInterface,
      tokenService: token_service.Service
      ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.settingsService = settingsService
    result.walletAccountService = walletAccountService
    result.transactionService = transactionService
    result.ethService = ethService
    result.networkService = networkService
    result.tokenService = tokenService

  proc confirmTransaction(self: Service, trxType: string, ensUsername: string, transactionHash: string) =
    self.pendingEnsUsernames.excl(ensUsername)
    let data = EnsTransactionArgs(transactionHash: transactionHash, ensUsername: ensUsername, transactionType: $trxType)
    self.events.emit(SIGNAL_ENS_TRANSACTION_CONFIRMED, data)

  proc revertTransaction(self: Service, trxType: string, ensUsername: string, transactionHash: string,
    revertReason: string) =
    self.pendingEnsUsernames.excl(ensUsername)
    let data = EnsTransactionArgs(transactionHash: transactionHash, ensUsername: ensUsername, transactionType: $trxType,
    revertReason: revertReason)
    self.events.emit(SIGNAL_ENS_TRANSACTION_REVERTED, data)

  proc doConnect(self: Service) =
    self.events.on(PendingTransactionTypeDto.RegisterENS.event) do(e: Args):
      var receivedData = TransactionMinedArgs(e)
      if receivedData.success:
        self.confirmTransaction($PendingTransactionTypeDto.RegisterENS, receivedData.data, receivedData.transactionHash)
      else:
        self.revertTransaction($PendingTransactionTypeDto.RegisterENS, receivedData.data, receivedData.transactionHash,
        receivedData.revertReason)

    self.events.on(PendingTransactionTypeDto.SetPubKey.event) do(e: Args):
      var receivedData = TransactionMinedArgs(e)
      if receivedData.success:
        self.confirmTransaction($PendingTransactionTypeDto.SetPubKey, receivedData.data, receivedData.transactionHash)
      else:
        self.revertTransaction($PendingTransactionTypeDto.SetPubKey, receivedData.data, receivedData.transactionHash,
        receivedData.revertReason)

  proc init*(self: Service) =
    self.doConnect()

    # Response of `transactionService.getPendingTransactions()` should be appropriate DTO, that's not added at the moment
    # but once we add it, need to update this block here, since we won't need to parse json manually here.
    let pendingTransactions = self.transactionService.getPendingTransactions()
    if (pendingTransactions.kind == JArray and pendingTransactions.len > 0):
      for trx in pendingTransactions.getElems():
        let transactionType = trx["type"].getStr
        if transactionType == $PendingTransactionTypeDto.RegisterENS or
          transactionType == $PendingTransactionTypeDto.SetPubKey:
          self.pendingEnsUsernames.incl trx["additionalData"].getStr

  proc getMyPendingEnsUsernames*(self: Service): seq[string] =
    for i in self.pendingEnsUsernames.items:
      result.add(i)

  proc getAllMyEnsUsernames*(self: Service, includePending: bool): seq[string] =
    result = self.settingsService.getEnsUsernames()
    if(includePending):
      result.add(self.getMyPendingEnsUsernames())

  proc onEnsUsernameAvailabilityChecked*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "expected response is not a json object", methodName="onEnsUsernameAvailabilityChecked"
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
    var desiredEnsUsername = self.formatUsername(ensUsername, isStatus)
    var availability = ""
    if registeredEnsUsernames.filter(proc(x: string):bool = x == desiredEnsUsername).len > 0:
      let data = EnsUsernameAvailabilityArgs(availabilityStatus: ENS_AVAILABILITY_STATUS_ALREADY_CONNECTED)
      self.events.emit(SIGNAL_ENS_USERNAME_AVAILABILITY_CHECKED, data)
    else:
      let arg = CheckEnsAvailabilityTaskArg(
        tptr: cast[ByteAddress](checkEnsAvailabilityTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onEnsUsernameAvailabilityChecked",
        ensUsername: ensUsername,
        chainId: self.settingsService.getCurrentNetworkId(),
        isStatus: isStatus,
        myPublicKey: self.settingsService.getPublicKey(),
        myWalletAddress: self.walletAccountService.getWalletAccount(0).address
      )
      self.threadpool.start(arg)

  proc onEnsUsernameDetailsFetched*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "expected response is not a json object", methodName="onEnsUsernameDetailsFetched"
      # notify view, this is important
      self.events.emit(SIGNAL_ENS_USERNAME_DETAILS_FETCHED, EnsUsernameDetailsArgs())
      return

    var data = EnsUsernameDetailsArgs()
    discard responseObj.getProp("ensUsername", data.ensUsername)
    discard responseObj.getProp("address", data.address)
    discard responseObj.getProp("pubkey", data.pubkey)
    discard responseObj.getProp("isStatus", data.isStatus)
    discard responseObj.getProp("expirationTime", data.expirationTime)

    self.events.emit(SIGNAL_ENS_USERNAME_DETAILS_FETCHED, data)

  proc sntSymbol(networkType: NetworkType): string =
    if networkType == NetworkType.Mainnet:
      return "SNT"
    else:
      return "STT"

  proc getCurrentNetworkContractForName(self: Service, name: string): ContractDto =
    let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
    let networkDto = self.networkService.getNetwork(networkType)
    return self.ethService.findContract(networkDto.chainId, name)

  proc getCurrentNetworkErc20ContractForSymbol(self: Service, symbol: string = ""): Erc20ContractDto =
    let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
    let networkDto = self.networkService.getNetwork(networkType)
    return self.ethService.findErc20Contract(networkDto.chainId, if symbol.len > 0: symbol else: networkType.sntSymbol())

  proc fetchDetailsForEnsUsername*(self: Service, ensUsername: string) =
    var isStatus = false
    if ensUsername.endsWith(ens_utils.STATUS_DOMAIN):
      let onlyUsername = ensUsername.replace(ens_utils.STATUS_DOMAIN, "")
      let label = fromHex(FixedBytes[32], label(onlyUsername))
      let expTime = ExpirationTime(label: label)
      isStatus = true

    let arg = EnsUsernamDetailsTaskArg(
      tptr: cast[ByteAddress](ensUsernameDetailsTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onEnsUsernameDetailsFetched",
      ensUsername: ensUsername,
      chainId: self.settingsService.getCurrentNetworkId(),
      isStatus: isStatus
    )
    self.threadpool.start(arg)

  proc onGasPriceFetched*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "expected response is not a json object", methodName="onGasPriceFetched"
      # notify view, this is important
      self.events.emit(SIGNAL_GAS_PRICE_FETCHED, GasPriceArgs(gasPrice: "0"))
      return

    var gasPriceHex: string
    if(not responseObj.getProp("gasPrice", gasPriceHex)):
      info "expected response doesn't contain gas price", methodName="onGasPriceFetched"
      # notify view, this is important
      self.events.emit(SIGNAL_GAS_PRICE_FETCHED, GasPriceArgs(gasPrice: "0"))
      return

    let gasPrice = $fromHex(Stuint[256], gasPriceHex)
    let parsedGasPrice = parseFloat(wei2gwei(gasPrice))
    var data = GasPriceArgs(gasPrice: fmt"{parsedGasPrice:.3f}")
    self.events.emit(SIGNAL_GAS_PRICE_FETCHED, data)

  proc fetchGasPrice*(self: Service) =
    let arg = QObjectTaskArg(
      tptr: cast[ByteAddress](fetchGasPriceTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onGasPriceFetched"
    )
    self.threadpool.start(arg)

  proc extractCoordinates(self: Service, pubkey: string):tuple[x: string, y:string] =
    result = ("0x" & pubkey[4..67], "0x" & pubkey[68..131])

  proc setPubKeyGasEstimate*(self: Service, ensUsername: string, address: string): int = 
    try:
      let
        chainId = self.settingsService.getCurrentNetworkId()
        txData = ens_utils.buildTransaction(parseAddress(address), 0.u256)

      let resp = status_ens.setPubKeyEstimate(chainId, %txData, ensUsername,
        singletonInstance.userProfile.getPubKey())
      result = resp.result.getInt
    except Exception as e:
      result = 80000
      error "error occurred", methodName="setPubKeyGasEstimate", msg = e.msg

  proc setPubKey*(
      self: Service,
      ensUsername: string,
      address: string,
      gas: string,
      gasPrice: string, 
      maxPriorityFeePerGas: string,
      maxFeePerGas: string,
      password: string
    ): string =    
    try:
      let
        chainId = self.settingsService.getCurrentNetworkId()
        eip1559Enabled = self.settingsService.isEIP1559Enabled()
        txData = ens_utils.buildTransaction(parseAddress(address), 0.u256, gas, gasPrice,
          eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas)

      let resp = status_ens.setPubKey(chainId, %txData, password, ensUsername.addDomain(),
        singletonInstance.userProfile.getPubKey())
      let hash = resp.result.getStr

      let resolverAddress = status_ens.resolver(chainId, ensUsername.addDomain()).result.getStr
      self.transactionService.trackPendingTransaction(hash, $address, resolverAddress,
        $PendingTransactionTypeDto.SetPubKey, ensUsername)
      self.pendingEnsUsernames.incl(ensUsername)

      result = $(%* { "result": hash, "success": true })
    except Exception as e:
      error "error occurred", methodName="setPubKey", msg = e.msg
      result = $(%* { "result": e.msg, "success": false })

  proc releaseEnsEstimate*(self: Service, ensUsername: string, address: string): int =
    try:
      let
        chainId = self.settingsService.getCurrentNetworkId()
        txData = ens_utils.buildTransaction(parseAddress(address), 0.u256)

      let resp = status_ens.releaseEstimate(chainId, %txData, ensUsername)
      result = resp.result.getInt
    except Exception as e:
      error "error occurred", methodName="releaseEnsEstimate", msg = e.msg
      result = 100000

  proc release*(
      self: Service,
      ensUsername: string,
      address: string,
      gas: string,
      gasPrice: string,
      password: string
    ): string =    
    try:
      let
        chainId = self.settingsService.getCurrentNetworkId()
        txData = ens_utils.buildTransaction(parseAddress(address), 0.u256, gas, gasPrice)

      let resp = status_ens.release(chainId, %txData, password, ensUsername)
      let hash = resp.result.getStr

      let ensUsernamesContract = self.ethService.findContract(chainId, "ens-usernames")
      self.transactionService.trackPendingTransaction(hash, address, $ensUsernamesContract.address,
        $PendingTransactionTypeDto.ReleaseENS, ensUsername)
      self.pendingEnsUsernames.excl(ensUsername)

      result = $(%* { "result": hash, "success": true })
    except RpcException as e:
      error "error occurred", methodName="release", msg = e.msg
      result = $(%* { "result": e.msg, "success": false })

  proc getEnsRegisteredAddress*(self: Service): string =
    let contractDto = self.getCurrentNetworkContractForName("ens-usernames")
    if contractDto != nil:
      return $contractDto.address

  proc registerENSGasEstimate*(self: Service, ensUsername: string, address: string): int =
    try:
      let
        chainId = self.settingsService.getCurrentNetworkId()
        txData = ens_utils.buildTransaction(parseAddress(address), 0.u256)

      let resp = status_ens.registerEstimate(chainId, %txData, ensUsername,
        singletonInstance.userProfile.getPubKey())
      result = resp.result.getInt
    except Exception as e:
      result = 380000
      error "error occurred", methodName="registerENSGasEstimate", msg = e.msg

  proc registerEns*(
      self: Service,
      username: string,
      address: string,
      gas: string,
      gasPrice: string, 
      maxPriorityFeePerGas: string,
      maxFeePerGas: string,
      password: string
    ): string =    
    try:
      let
        networkType = self.settingsService.getCurrentNetwork().toNetworkType()
        network = self.networkService.getNetwork(networkType)
        chainId = network.chainId
        eip1559Enabled = self.settingsService.isEIP1559Enabled()
        txData = ens_utils.buildTransaction(parseAddress(address), 0.u256, gas, gasPrice,
          eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas)

      let resp = status_ens.register(chainId, %txData, password, username,
        singletonInstance.userProfile.getPubKey())
      let hash = resp.result.getStr
      let sntContract = self.ethService.findErc20Contract(chainId, network.sntSymbol())
      let ensUsername = self.formatUsername(username, true)
      self.transactionService.trackPendingTransaction(hash, address, $sntContract.address,
        $PendingTransactionTypeDto.RegisterEns, ensUsername)

      self.pendingEnsUsernames.incl(ensUsername)
      result = $(%* { "result": hash, "success": true })
    except Exception as e:
      error "error occurred", methodName="registerEns", msg = e.msg
      result = $(%* { "result": e.msg, "success": false })

  proc getSNTBalance*(self: Service): string =
    let address = self.walletAccountService.getWalletAccount(0).address
    let sntContract = self.getCurrentNetworkErc20ContractForSymbol()

    var postfixedAccount: string = address
    postfixedAccount.removePrefix("0x")
    let payload = %* [{
      "to": $sntContract.address,
      "from": address,
      "data": fmt"0x70a08231000000000000000000000000{postfixedAccount}"
    }, "latest"]
    let response = status_eth.doEthCall(payload)
    let balance = response.result.getStr

    var decimals = 18

    let allTokens = self.tokenService.getTokens()
    for t in allTokens:
      if(t.address == sntContract.address):
        decimals = t.decimals
        break

    result = ens_utils.hex2Token(balance, decimals)

  proc getStatusToken*(self: Service): string =
    let sntContract = self.getCurrentNetworkErc20ContractForSymbol()
    let jsonObj = %* {
      "name": sntContract.name,
      "symbol": sntContract.symbol,
      "address": sntContract.address
    }
    return $jsonObj

  proc resourceUrl*(self: Service, username: string): (string, string, string) =
    try:
      let chainId = self.settingsService.getCurrentNetworkId()
      let response = status_ens.resourceURL(chainId, username)
      return (response.result{"Scheme"}.getStr, response.result{"Host"}.getStr, response.result{"Path"}.getStr)
    except Exception as e:
      error "Error getting ENS resourceUrl", username=username, exception=e.msg
      raise