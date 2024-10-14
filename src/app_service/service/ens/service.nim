import NimQml, Tables, json, sequtils, strutils, stint, chronicles
import web3/ethtypes, stew/byteutils, nimcrypto, json_serialization

import app/core/eventemitter
import app/core/tasks/[qt, threadpool]

import app/global/global_singleton
import backend/ens as status_ens
import backend/backend as status_go_backend

import utils as ens_utils
import app_service/service/settings/service as settings_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/transaction/service as transaction_service
import app_service/service/network/service as network_service
import app_service/service/token/service as token_service
import app_service/service/eth/dto/coder
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
    txHash*: string
    ensUsername*: string
    transactionType*: string

  EnsTxResultArgs* = ref object of Args
    transactionType*: string
    chainId*: int
    ensUsername*: string
    txHash*: string
    error*: string

# Signals which may be emitted by this service:
const SIGNAL_ENS_USERNAME_AVAILABILITY_CHECKED* = "ensUsernameAvailabilityChecked"
const SIGNAL_ENS_USERNAME_DETAILS_FETCHED* = "ensUsernameDetailsFetched"
const SIGNAL_ENS_TRANSACTION_SENT* = "ensTransactionSent"
const SIGNAL_ENS_TRANSACTION_CONFIRMED* = "ensTransactionConfirmed"
const SIGNAL_ENS_TRANSACTION_REVERTED* = "ensTransactionReverted"

QtObject:
  type
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      pendingEnsUsernames*: Table[string, EnsUsernameDto]
      settingsService: settings_service.Service
      walletAccountService: wallet_account_service.Service
      transactionService: transaction_service.Service
      networkService: network_service.Service
      tokenService: token_service.Service

  ## Forward declarations
  proc add*(self: Service, chainId: int, username: string): bool
  proc remove*(self: Service, chainId: int, username: string): bool

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
    result.pendingEnsUsernames = initTable[string, EnsUsernameDto]()
    result.settingsService = settingsService
    result.walletAccountService = walletAccountService
    result.transactionService = transactionService
    result.networkService = networkService
    result.tokenService = tokenService

  proc getChainId(self: Service): int =
    return self.networkService.getAppNetwork().chainId

  proc makeKey(username: string, chainId: int): string =
    return $username & "-" & $chainId

  proc formatUsername(self: Service, username: string, isStatus: bool): string =
    result = username
    if isStatus:
      result = result & ens_utils.STATUS_DOMAIN

  proc updateEnsUsernames(self: Service, chainId: int, transactionHash: string, status: string) =
    if status == TxStatusPending:
      return

    # find ens username by transactionHash
    var ensDto = EnsUsernameDto()
    for _, value in self.pendingEnsUsernames.pairs:
      if value.txHash == transactionHash:
        ensDto = value
        break

    if ensDto.username.len == 0:
      return

    let key = makeKey(ensDto.username, chainId)
    if status == TxStatusSuccess:
      self.pendingEnsUsernames[key].txStatus = TxStatusSuccess
      let data = EnsTransactionArgs(txHash: transactionHash, ensUsername: ensDto.username, transactionType: $ensDto.txType)
      self.events.emit(SIGNAL_ENS_TRANSACTION_CONFIRMED, data)
      return
    if status == TxStatusFailed:
      self.pendingEnsUsernames[key].txStatus = TxStatusFailed
      let data = EnsTransactionArgs(txHash: transactionHash, ensUsername: ensDto.username, transactionType: $ensDto.txType)
      self.events.emit(SIGNAL_ENS_TRANSACTION_REVERTED, data)
      return
    error "Error updating ens username status", message = "unknown status: " & status

  proc doConnect(self: Service) =
    self.events.on(SIGNAL_TRANSACTION_SENT) do(e:Args):
      let args = TransactionSentArgs(e)
      if args.txType != SendType.ENSRegister and args.txType != SendType.ENSSetPubKey and args.txType != SendType.ENSRelease:
        return

      var err = args.error
      var dto = EnsUsernameDto(
        chainId: args.chainId,
        username: args.username,
        txHash: args.txHash,
        txStatus: TxStatusPending
      )

      if args.txType == SendType.ENSRegister:
        dto.txType = RegisterENS
        if err.len == 0:
          let ensUsernameFinal = self.formatUsername(args.username, true)
          if not self.add(args.chainId, ensUsernameFinal):
            err = "failed to add ens username"
            error "error", err
      elif args.txType == SendType.ENSSetPubKey:
        dto.txType = SetPubKey
        if err.len == 0:
          let usernameWithDomain = args.username.addDomain()
          if not self.add(args.chainId, usernameWithDomain):
            err = "failed to set ens username"
            error "error", err
      elif args.txType == SendType.ENSRelease:
        dto.txType = ReleaseENS
        if err.len == 0:
          let ensUsernameFinal = self.formatUsername(args.username, true)
          if not self.remove(args.chainId, ensUsernameFinal):
            err = "failed to remove ens username"
            error "error", err

      self.pendingEnsUsernames[makeKey(dto.username, args.chainId)] = dto

      let data = EnsTxResultArgs(transactionType: $dto.txType, chainId: args.chainId, ensUsername: args.username, txHash: args.txHash, error: err)
      self.events.emit(SIGNAL_ENS_TRANSACTION_SENT, data)

    self.events.on(SIGNAL_TRANSACTION_STATUS_CHANGED) do(e:Args):
      let args = TransactionStatusArgs(e)
      self.updateEnsUsernames(args.data.chainId, args.data.hash, args.data.status)

  proc init*(self: Service) =
    self.doConnect()

    for trx in self.transactionService.getPendingTransactions():
      if trx.typeValue == $PendingTransactionTypeDto.RegisterENS or
        trx.typeValue == $PendingTransactionTypeDto.SetPubKey or
        trx.typeValue == $PendingTransactionTypeDto.ReleaseENS:
          let dto = EnsUsernameDto(chainId: trx.chainId, username: trx.additionalData)
          self.pendingEnsUsernames[makeKey(dto.username, dto.chainId)] = dto

  proc getMyPendingEnsUsernames*(self: Service): seq[EnsUsernameDto] =
    for i in self.pendingEnsUsernames.values:
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
    try:
      let responseObj = response.parseJson
      if responseObj.kind != JObject:
        raise newException(CatchableError, "expected response is not a json object")

      if responseObj.contains("error"):
        raise newException(CatchableError, responseObj{"error"}.getStr)

      var availablilityStatus: string
      discard responseObj.getProp("availability", availablilityStatus)
      let data = EnsUsernameAvailabilityArgs(availabilityStatus: availablilityStatus)
      self.events.emit(SIGNAL_ENS_USERNAME_AVAILABILITY_CHECKED, data)
    except Exception as e:
      error "error: ", procName="onEnsUsernameAvailabilityChecked", msg = e.msg
      # notify view, this is important
      self.events.emit(SIGNAL_ENS_USERNAME_AVAILABILITY_CHECKED, EnsUsernameAvailabilityArgs())

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
        tptr: checkEnsAvailabilityTask,
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
    try:
      let responseObj = response.parseJson
      if (responseObj.kind != JObject):
        raise newException(CatchableError, "expected response is not a json object")

      if responseObj.contains("error"):
        raise newException(CatchableError, responseObj{"error"}.getStr)

      var data = EnsUsernameDetailsArgs()
      discard responseObj.getProp("chainId", data.chainId)
      discard responseObj.getProp("ensUsername", data.ensUsername)
      discard responseObj.getProp("address", data.address)
      discard responseObj.getProp("pubkey", data.pubkey)
      discard responseObj.getProp("isStatus", data.isStatus)
      discard responseObj.getProp("expirationTime", data.expirationTime)
      self.events.emit(SIGNAL_ENS_USERNAME_DETAILS_FETCHED, data)
    except Exception as e:
      error "error: ", procName="onEnsUsernameDetailsFetched", msg = e.msg
      # notify view, this is important
      self.events.emit(SIGNAL_ENS_USERNAME_DETAILS_FETCHED, EnsUsernameDetailsArgs())

  proc fetchDetailsForEnsUsername*(self: Service, chainId: int, ensUsername: string) =
    var isStatus = false
    var username = ensUsername
    if ensUsername.endsWith(ens_utils.STATUS_DOMAIN):
      username = ensUsername.replace(ens_utils.STATUS_DOMAIN, "")
      isStatus = true

    let arg = EnsUsernamDetailsTaskArg(
      tptr: ensUsernameDetailsTask,
      vptr: cast[ByteAddress](self.vptr),
      slot: "onEnsUsernameDetailsFetched",
      ensUsername: username,
      chainId: chainId,
      isStatus: isStatus
    )
    self.threadpool.start(arg)

  proc extractCoordinates(self: Service, pubkey: string):tuple[x: string, y:string] =
    result = ("0x" & pubkey[4..67], "0x" & pubkey[68..131])

  proc getEnsRegisteredAddress*(self: Service): string =
    return status_ens.getRegistrarAddress(self.getChainId()).result.getStr

  proc resourceUrl*(self: Service, username: string): (string, string, string) =
    try:
      let response = status_ens.resourceURL(self.getChainId(), username)
      return (response.result{"Scheme"}.getStr, response.result{"Host"}.getStr, response.result{"Path"}.getStr)
    except Exception as e:
      error "Error getting ENS resourceUrl", username=username, exception=e.msg
      raise