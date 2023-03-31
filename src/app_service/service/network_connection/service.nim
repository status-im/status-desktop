import NimQml, chronicles, Tables, strutils, sequtils, sugar, strformat, json

import ../../../app/global/global_singleton
import ../../../app/core/eventemitter
import ../../../app/core/signals/types

import ../wallet_account/service as wallet_service
import ../network/service as network_service
import ../node/service as node_service
import ../collectible/service as collectible_service
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

const SIGNAL_CONNECTION_UPDATE* = "signalConnectionUpdate"
const SIGNAL_REFRESH_COLLECTIBLES* = "signalRefreshCollectibles"

type NetworkConnectionsArgs* = ref object of Args
  website*: string
  completelyDown*: bool
  connectionState*: ConnectionState
  chainIds*: string
  lastCheckedAt*: int
  timeToAutoRetryInSecs*: int

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
    timer: newQTimer()
  )

QtObject:
  type Service* = ref object of QObject
    closingApp: bool
    events: EventEmitter
    walletService: wallet_service.Service
    networkService: network_service.Service
    nodeService: node_service.Service
    connectionStatus: Table[string, ConnectionStatus]

  # Forward declaration
  proc updateBlockchainsStatus(self: Service, completelyDown: bool, chaindIdsDown: seq[int], at: int)
  proc updateMarketOrCollectibleStatus(self: Service, website: string, isDown: bool, at: int)
  proc getChainIdsDown(self: Service, message: string): (bool, seq[int])
  proc getIsDown(self: Service,message: string): bool

  proc delete*(self: Service) =
    self.closingApp = true
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    walletService: wallet_service.Service,
    networkService: network_service.Service,
    nodeService: node_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.closingApp = false
    result.events = events
    result.walletService = walletService
    result.networkService = networkService
    result.nodeService = nodeService
    result.connectionStatus = {BLOCKCHAINS: newConnectionStatus(),
                                MARKET: newConnectionStatus(),
                                COLLECTIBLES: newConnectionStatus()}.toTable

  proc init*(self: Service) =
    self.events.on(SignalType.Wallet.event) do(e:Args):
      var data = WalletSignal(e)
      case data.eventType:
        of "wallet-blockchain-status-changed":
          if self.nodeService.isConnected():
            let (allDown, chainsDown) =  self.getChainIdsDown(data.message)
            self.updateBlockchainsStatus(allDown, chainsDown, data.at)
        of "wallet-market-status-changed":
          if self.nodeService.isConnected():
            self.updateMarketOrCollectibleStatus(MARKET, self.getIsDown(data.message), data.at)
        of "wallet-collectible-status-changed":
          if self.nodeService.isConnected():
            self.updateMarketOrCollectibleStatus(COLLECTIBLES, self.getIsDown(data.message), data.at)

    self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
      if self.connectionStatus.hasKey(MARKET):
        let connectionStatus = self.connectionStatus[MARKET]
        self.updateMarketOrCollectibleStatus(MARKET, connectionStatus.completelyDown, connectionStatus.lastCheckedAt)

      if self.connectionStatus.hasKey(BLOCKCHAINS):
        let connectionStatus = self.connectionStatus[BLOCKCHAINS]
        self.updateBlockchainsStatus(connectionStatus.completelyDown, connectionStatus.chainIds, connectionStatus.lastCheckedAt)

    self.events.on(SIGNAL_OWNED_COLLECTIBLES_UPDATE_ERROR) do(e:Args):
      if self.connectionStatus.hasKey(COLLECTIBLES):
        let connectionStatus = self.connectionStatus[COLLECTIBLES]
        self.updateMarketOrCollectibleStatus(COLLECTIBLES, connectionStatus.completelyDown, connectionStatus.lastCheckedAt)

  proc getIsDown(self: Service, message: string): bool =
    result = message == "down"

  proc getChainIdsDown(self: Service, message: string): (bool, seq[int]) =
    let chainStatusTable =  parseJson(message)
    var allDown: bool = true
    var chaindIdsDown: seq[int] = @[]

    # checking all down we check all networks and for chainIds to be displayed as down
    # we only check for networks currently active (for test net only testnet networks etc...)
    let currentChainIds = self.networkService.getNetworks().map(a => a.chainId)
    let allChainIds = self.networkService.fetchNetworks().map(a => a.chainId)
    if chainStatusTable.kind != JNull:
      for id in allChainIds:
        if chainStatusTable[$id].kind != JNull:
          let isDown = self.getIsDown(chainStatusTable[$id].getStr)
          if not isDown:
            allDown = false
          if currentChainIds.contains(id):
            if isDown:
              chaindIdsDown.add(id)
    return (allDown, chaindIdsDown)

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
      timeToAutoRetryInSecs: connectionStatus.timeToAutoRetryInSecs
      )

  proc updateConnectionStatus(self: Service,
    website: string,
    connectionState: ConnectionState,
    completelyDown: bool,
    chainIds: seq[int],
    lastCheckedAt: int,
    timeToAutoRetryInSecs: int
    ) =
      if self.connectionStatus.hasKey(website):
        self.connectionStatus[website].connectionState = connectionState
        self.connectionStatus[website].completelyDown = completelyDown
        self.connectionStatus[website].chainIds = chainIds
        self.connectionStatus[website].lastCheckedAt = lastCheckedAt
        self.connectionStatus[website].timeToAutoRetryInSecs = timeToAutoRetryInSecs

  proc increaseTimer(self: Service, connectionStatus: ConnectionStatus): int  =
    var backOffTimer: int = connectionStatus.timeToAutoRetryInSecs
     # Is down even after retry we need to increase the timer duration
    if connectionStatus.connectionState == ConnectionState.Retrying:
      let index = BACKOFF_TIMERS.find(backOffTimer)
      if index != -1 and index < BACKOFF_TIMERS.len:
        backOffTimer = BACKOFF_TIMERS[index + 1]
    return backOffTimer

  proc updateMarketOrCollectibleStatus(self: Service, website: string, isDown: bool, at: int) =
    if self.connectionStatus.hasKey(website):
      if isDown:
        self.updateConnectionStatus(website, ConnectionState.Failed, true, @[], at, self.increaseTimer(self.connectionStatus[website]))
        # restart timer
        signalConnect(self.connectionStatus[website].timer, "timeout()", self, website&"Retry()", 2)
        self.connectionStatus[website].timer.setInterval(self.connectionStatus[website].timeToAutoRetryInSecs*1000)
        self.connectionStatus[website].timer.start()

        # trigger event
        self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(website, self.connectionStatus[website]))
      else:
        # site was completely down and is back up now
        if self.connectionStatus[website].completelyDown:
          self.connectionStatus[website] = newConnectionStatus()
          # trigger event
          self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(website, self.connectionStatus[website]))


  proc updateBlockchainsStatus(self: Service, completelyDown: bool, chaindIdsDown: seq[int], at: int) =
    if self.connectionStatus.hasKey(BLOCKCHAINS):
      # if all the networks are down for the BLOCKCHAINS
      if completelyDown:
        var backOffTimer: int = self.connectionStatus[BLOCKCHAINS].timeToAutoRetryInSecs
        if self.connectionStatus[BLOCKCHAINS].completelyDown:
          backOffTimer = self.increaseTimer(self.connectionStatus[BLOCKCHAINS])
        self.updateConnectionStatus(BLOCKCHAINS, ConnectionState.Failed, true, chaindIdsDown, at, backOffTimer)
        # restart timer
        signalConnect(self.connectionStatus[BLOCKCHAINS].timer, "timeout()", self, BLOCKCHAINS&"Retry()", 2)
        self.connectionStatus[BLOCKCHAINS].timer.setInterval(self.connectionStatus[BLOCKCHAINS].timeToAutoRetryInSecs*1000)
        self.connectionStatus[BLOCKCHAINS].timer.start()

        # trigger event
        self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(BLOCKCHAINS, self.connectionStatus[BLOCKCHAINS]))

      # if all the networks are not down for the website
      else:
        # case where a down website is back up
        if self.connectionStatus[BLOCKCHAINS].completelyDown or (chaindIdsDown.len == 0 and self.connectionStatus[BLOCKCHAINS].chainIds.len != 0):
          self.connectionStatus[BLOCKCHAINS] = newConnectionStatus()
          self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(BLOCKCHAINS, self.connectionStatus[BLOCKCHAINS]))

        # case where a some of networks on the website are down
        if chaindIdsDown.len > 0:
          self.updateConnectionStatus(BLOCKCHAINS, ConnectionState.Failed, false, chaindIdsDown, at, self.increaseTimer(self.connectionStatus[BLOCKCHAINS]))
          # restart timer
          signalConnect(self.connectionStatus[BLOCKCHAINS].timer, "timeout()", self, BLOCKCHAINS&"Retry()", 2)
          self.connectionStatus[BLOCKCHAINS].timer.setInterval(self.connectionStatus[BLOCKCHAINS].timeToAutoRetryInSecs*1000)
          self.connectionStatus[BLOCKCHAINS].timer.start()

          # trigger event
          self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(BLOCKCHAINS, self.connectionStatus[BLOCKCHAINS]))

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
      self.events.emit(SIGNAL_REFRESH_COLLECTIBLES, Args())

  proc networkConnected*(self: Service, connected: bool) =
    if connected:
      self.walletService.reloadAccountTokens()
      self.events.emit(SIGNAL_REFRESH_COLLECTIBLES, Args())
    else:
      if(self.connectionStatus.hasKey(BLOCKCHAINS)):
        self.connectionStatus[BLOCKCHAINS].timer.stop()
        self.connectionStatus[BLOCKCHAINS] = newConnectionStatus()
      if(self.connectionStatus.hasKey(MARKET)):
        self.connectionStatus[MARKET].timer.stop()
        self.connectionStatus[MARKET] = newConnectionStatus()
      if(self.connectionStatus.hasKey(COLLECTIBLES)):
        self.connectionStatus[COLLECTIBLES].timer.stop()
        self.connectionStatus[COLLECTIBLES] = newConnectionStatus()

  proc checkIfConnected*(self: Service, website: string): bool =
    if self.connectionStatus.hasKey(website) and self.connectionStatus[website].completelyDown:
      return false
    return true

