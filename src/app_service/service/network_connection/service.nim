import NimQml, chronicles, Tables, strutils, sequtils, sugar, strformat, json

import ../../../app/global/global_singleton
import ../../../app/core/eventemitter
import ../../../app/core/signals/types

import ../collectible/service as collectible_service
import ../wallet_account/service as wallet_service
import ../network/service as network_service
import ../node/service as node_service
import ../../../backend/backend as backend

logScope:
  topics = "network-connection-service"

type ConnectionState* {.pure.} = enum
  Successful = 0,
  Failed = 1,
  Retrying = 2

type ConnectionStatus* = ref object of RootObj
    connectionState*: ConnectionState
    completelyDown*: bool
    chainIds*: seq[int]
    lastCheckedAt*: int
    timeToAutoRetryInSecs*: int
    timer*: QTimer
    withCache*: bool

const SIGNAL_CONNECTION_UPDATE* = "signalConnectionUpdate"
const SIGNAL_REFRESH_COLLECTIBLES* = "signalRefreshCollectibles"

type NetworkConnectionsArgs* = ref object of Args
  website*: string
  completelyDown*: bool
  connectionState*: ConnectionState
  chainIds*: string
  lastCheckedAt*: int
  timeToAutoRetryInSecs*: int
  withCache*: bool

type RetryCollectibleArgs* = ref object of Args
   addresses*: seq[string]

const BLOCKCHAINS* = "blockchains"
const MARKET* = "market"
const COLLECTIBLES* = "collectibles"
const BACKOFF_TIMERS* = [30, 60, 180, 600, 3600, 10800]

include  ../../common/json_utils

proc newConnectionStatus(): ConnectionStatus =
  return ConnectionStatus(
    connectionState: ConnectionState.Successful,
    completelyDown: false,
    chainIds: @[],
    lastCheckedAt: 0,
    timeToAutoRetryInSecs: BACKOFF_TIMERS[0],
    timer: newQTimer(),
    withCache: false
  )

QtObject:
  type Service* = ref object of QObject
    closingApp: bool
    events: EventEmitter
    walletService: wallet_service.Service
    networkService: network_service.Service
    collectibleService: collectible_service.Service
    nodeService: node_service.Service
    connectionStatus: Table[string, ConnectionStatus]

  # Forward declaration
  proc checkConnected(self: Service)

  proc delete*(self: Service) =
    self.closingApp = true
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    walletService: wallet_service.Service,
    networkService: network_service.Service,
    collectibleService: collectible_service.Service,
    nodeService: node_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.closingApp = false
    result.events = events
    result.walletService = walletService
    result.networkService = networkService
    result.collectibleService = collectibleService
    result.nodeService = nodeService
    result.connectionStatus = {BLOCKCHAINS: newConnectionStatus(),
                                MARKET: newConnectionStatus(),
                                COLLECTIBLES: newConnectionStatus()}.toTable

  proc init*(self: Service) =
    self.events.on(SignalType.Wallet.event) do(e:Args):
      var data = WalletSignal(e)
      case data.eventType:
        of "wallet-tick-check-connected":
          self.checkConnected()

  proc getFormattedStringForChainIds(self: Service, chainIds: seq[int]): string =
    var result: string = ""
    for chainId in chainIds:
      if result.isEmptyOrWhitespace:
        result = $chainId
      else:
        result = result & ";" & $chainId
    return result

  proc convertConnectionStatusToNetworkConnectionsArgs(self: Service, website: string, connectionStatus: ConnectionStatus): NetworkConnectionsArgs =
    result = NetworkConnectionsArgs(
      website: website,
      completelyDown: connectionStatus.completelyDown,
      connectionState: connectionStatus.connectionState,
      chainIds: self.getFormattedStringForChainIds(connectionStatus.chainIds),
      lastCheckedAt: connectionStatus.lastCheckedAt,
      timeToAutoRetryInSecs: connectionStatus.timeToAutoRetryInSecs,
      withCache: connectionStatus.withCache
      )

  proc blockchainsRetry*(self: Service) {.slot.} =
    if(self.connectionStatus.hasKey(BLOCKCHAINS)):
      self.connectionStatus[BLOCKCHAINS].timer.stop()
      self.connectionStatus[BLOCKCHAINS].connectionState = ConnectionState.Retrying
      self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(BLOCKCHAINS, self.connectionStatus[BLOCKCHAINS]))
      self.walletService.reloadAccountTokens()

  proc marketRetry*(self: Service) {.slot.} =
    if(self.connectionStatus.hasKey(MARKET)):
      self.connectionStatus[MARKET].timer.stop()
      self.connectionStatus[MARKET].connectionState = ConnectionState.Retrying
      self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(MARKET, self.connectionStatus[MARKET]))
      self.walletService.reloadAccountTokens()

  proc collectiblesRetry*(self: Service) {.slot.} =
    if(self.connectionStatus.hasKey(COLLECTIBLES)):
      self.connectionStatus[COLLECTIBLES].timer.stop()
      self.connectionStatus[COLLECTIBLES].connectionState = ConnectionState.Retrying
      self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(COLLECTIBLES, self.connectionStatus[COLLECTIBLES]))
      self.events.emit(SIGNAL_REFRESH_COLLECTIBLES, RetryCollectibleArgs(addresses: self.walletService.getAddresses()))

  # needs to be re-written once cache for market, blockchain and collectibles is implemented
  proc hasCache(self: Service,  website: string): bool =
      case website:
        of BLOCKCHAINS:
          return self.walletService.hasCache()
        of MARKET:
          return self.walletService.hasMarketCache()
        of COLLECTIBLES:
          return self.collectibleService.areCollectionsLoaded()

  proc checkStatus(self: Service, status: JsonNode, website: string) =
    var allDown: bool = true
    var lastCheckedAt: int = 0
    var chaindIdsDown: seq[int] = @[]

    # checking only for networks currently active (for test net only testnet networks etc...)
    let currentChainIds = self.networkService.getNetworks().map(a => a.chainId)
    for chainId, state in status:
      if state["up"].getBool:
        allDown = false
      # only add chains that belong to the test node or not based on current user setting
      if currentChainIds.contains(chainId.parseInt):
        lastCheckedAt = state["lastCheckedAt"].getInt
        if not state["up"].getBool:
          chaindIdsDown.add(chainId.parseInt)

    if self.connectionStatus.hasKey(website):
      self.connectionStatus[website].withCache = self.hasCache(website)
      # if all the networks are down for the website
      if allDown:
        if not self.connectionStatus[website].timer.isActive():
          var backOffTimer: int = self.connectionStatus[website].timeToAutoRetryInSecs

          # if all the networks are down for the website after a retry increment the backoff timer
          if self.connectionStatus[website].completelyDown and self.connectionStatus[website].connectionState == ConnectionState.Retrying:
            let index = BACKOFF_TIMERS.find(self.connectionStatus[website].timeToAutoRetryInSecs)
            if index != -1 and index < BACKOFF_TIMERS.len:
              backOffTimer = BACKOFF_TIMERS[index + 1]

          self.connectionStatus[website].connectionState = ConnectionState.Failed
          self.connectionStatus[website].completelyDown = true
          self.connectionStatus[website].lastCheckedAt = lastCheckedAt
          self.connectionStatus[website].timeToAutoRetryInSecs = backOffTimer
          self.connectionStatus[website].chainIds = chaindIdsDown
          signalConnect(self.connectionStatus[website].timer, "timeout()", self, website&"Retry()", 2)
          self.connectionStatus[website].timer.setInterval(backOffTimer*1000)
          self.connectionStatus[website].timer.start()

          self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(website, self.connectionStatus[website]))

      # if all the networks are not down for the website
      else:
        # case where a down website is back up
        if self.connectionStatus[website].completelyDown or (chaindIdsDown.len == 0 and self.connectionStatus[website].chainIds.len != 0):
          self.connectionStatus[website] = newConnectionStatus()
          self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(website, self.connectionStatus[website]))

        # case where a some of networks on the website are down
        if chaindIdsDown.len > 0:
          var backOffTimer: int = self.connectionStatus[website].timeToAutoRetryInSecs
          if self.connectionStatus[website].connectionState == ConnectionState.Retrying:
            let index = BACKOFF_TIMERS.find(self.connectionStatus[website].timeToAutoRetryInSecs)
            if index != -1 and index < BACKOFF_TIMERS.len:
              backOffTimer = BACKOFF_TIMERS[index + 1]

          self.connectionStatus[website].completelyDown = false
          self.connectionStatus[website].chainIds = chaindIdsDown
          self.connectionStatus[website].timeToAutoRetryInSecs = backOffTimer
          self.connectionStatus[website].connectionState = ConnectionState.Failed
          self.connectionStatus[website].lastCheckedAt = lastCheckedAt
          signalConnect(self.connectionStatus[website].timer, "timeout()", self, website&"Retry()", 2)
          self.connectionStatus[website].timer.setInterval(self.connectionStatus[website].timeToAutoRetryInSecs*1000)
          self.connectionStatus[website].timer.start()

          self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(website, self.connectionStatus[website]))

  proc checkMarketStatus(self: Service, status: JsonNode, website: string) =
    if self.connectionStatus.hasKey(website):
      self.connectionStatus[website].withCache = self.hasCache(website)
      if not status["up"].getBool:
        if not self.connectionStatus[website].timer.isActive():
          var backOffTimer: int = self.connectionStatus[website].timeToAutoRetryInSecs
          if self.connectionStatus[website].connectionState == ConnectionState.Retrying:
            let index = BACKOFF_TIMERS.find(self.connectionStatus[website].timeToAutoRetryInSecs)
            if index != -1 and index < BACKOFF_TIMERS.len:
              backOffTimer = BACKOFF_TIMERS[index + 1]

          self.connectionStatus[website].completelyDown = true
          self.connectionStatus[website].connectionState = ConnectionState.Failed
          self.connectionStatus[website].timeToAutoRetryInSecs = backOffTimer
          self.connectionStatus[website].lastCheckedAt = status["lastCheckedAt"].getInt
          signalConnect(self.connectionStatus[website].timer, "timeout()", self, website&"Retry()", 2)
          self.connectionStatus[website].timer.setInterval(self.connectionStatus[website].timeToAutoRetryInSecs*1000)
          self.connectionStatus[website].timer.start()
          self.events.emit(SIGNAL_CONNECTION_UPDATE,self.convertConnectionStatusToNetworkConnectionsArgs(website, self.connectionStatus[website]))
      else:
        # site was completely down and is back up now
        if self.connectionStatus[website].completelyDown:
          self.connectionStatus[website] = newConnectionStatus()
          self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(website, self.connectionStatus[website]))

  proc checkConnected(self: Service) =
    if(not singletonInstance.localAccountSensitiveSettings.getIsWalletEnabled()):
      return

    try:
      if self.nodeService.isConnected():
        let response = backend.checkConnected()
        self.checkStatus(response.result[BLOCKCHAINS], BLOCKCHAINS)
        self.checkStatus(response.result[COLLECTIBLES], COLLECTIBLES)
        self.checkMarketStatus(response.result[MARKET], MARKET)
    except Exception as e:
      let errDescription = e.msg
      error "error: ", errDescription
      return

  proc networkConnected*(self: Service) =
    self.walletService.reloadAccountTokens()
    self.events.emit(SIGNAL_REFRESH_COLLECTIBLES, RetryCollectibleArgs(addresses: self.walletService.getAddresses()))

  proc checkIfConnected*(self: Service, website: string): bool =
    if self.connectionStatus.hasKey(website) and self.connectionStatus[website].completelyDown:
      return false
    return true

