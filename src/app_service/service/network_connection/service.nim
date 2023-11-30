import NimQml, chronicles, Tables, strutils, sequtils, sugar, json

import ../../../app/global/global_singleton
import ../../../app/core/eventemitter
import ../../../app/core/signals/types

import app_service/service/wallet_account/service as wallet_service
import app_service/service/network/service as network_service
import app_service/service/node/service as node_service
import backend/connection_status as connection_status_backend
import app_service/service/token/service as token_service
import backend/collectibles as collectibles_backend

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

const SIGNAL_CONNECTION_UPDATE* = "signalConnectionUpdate"

type NetworkConnectionsArgs* = ref object of Args
  website*: string
  completelyDown*: bool
  connectionState*: ConnectionState
  chainIds*: string
  lastCheckedAt*: int

const BLOCKCHAINS* = "blockchains"
const MARKET* = "market"
const COLLECTIBLES* = "collectibles"

include  ../../common/json_utils

proc newConnectionStatus(): ConnectionStatus =
  return ConnectionStatus(
    connectionState: ConnectionState.Successful,
    completelyDown: false,
    chainIds: @[],
    lastCheckedAt: connection_status_backend.INVALID_TIMESTAMP,
  )

QtObject:
  type Service* = ref object of QObject
    closingApp: bool
    events: EventEmitter
    walletService: wallet_service.Service
    networkService: network_service.Service
    nodeService: node_service.Service
    tokenService: token_service.Service
    connectionStatus: Table[string, ConnectionStatus]

  # Forward declaration
  proc updateSimpleStatus(self: Service, website: string, isDown: bool, at: int)
  proc updateMultichainStatus(self: Service, website: string, completelyDown: bool, chaindIdsDown: seq[int], at: int)
  proc getChainIdsDown(self: Service, chainStatusTable: ConnectionStatusNotification): (bool, bool, seq[int], int)
  proc getIsDown(message: string): bool
  proc getChainStatusTable(message: string): ConnectionStatusNotification

  proc delete*(self: Service) =
    self.closingApp = true
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    walletService: wallet_service.Service,
    networkService: network_service.Service,
    nodeService: node_service.Service,
    tokenService: token_service.Service
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.closingApp = false
    result.events = events
    result.walletService = walletService
    result.networkService = networkService
    result.nodeService = nodeService
    result.tokenService = tokenService
    result.connectionStatus = {BLOCKCHAINS: newConnectionStatus(),
                                MARKET: newConnectionStatus(),
                                COLLECTIBLES: newConnectionStatus()}.toTable

  proc init*(self: Service) =
    self.events.on(SignalType.Wallet.event) do(e:Args):
      var data = WalletSignal(e)
      case data.eventType:
        of "wallet-blockchain-status-changed":
          if self.nodeService.isConnected():
            let chainStateTable = getChainStatusTable(data.message)
            let (allKnown, allDown, chainsDown, at) =  self.getChainIdsDown(chainStateTable)
            self.updateMultichainStatus(BLOCKCHAINS, allDown, chainsDown, data.at)
        of "wallet-market-status-changed":
          if self.nodeService.isConnected():
            self.updateSimpleStatus(MARKET, getIsDown(data.message), data.at)
        of "wallet-collectible-status-changed":
          if self.nodeService.isConnected():
            let chainStateTable = fromJson(parseJson(data.message), ConnectionStatusNotification)
            let (allKnown, allDown, chainsDown, at) = self.getChainIdsDown(chainStateTable)
            if allKnown:
              self.updateMultichainStatus(COLLECTIBLES, allDown, chainsDown, at)

    self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
      if self.connectionStatus.hasKey(MARKET):
        let connectionStatus = self.connectionStatus[MARKET]
        self.updateSimpleStatus(MARKET, connectionStatus.completelyDown, connectionStatus.lastCheckedAt)

      if self.connectionStatus.hasKey(BLOCKCHAINS):
        let connectionStatus = self.connectionStatus[BLOCKCHAINS]
        self.updateMultichainStatus(BLOCKCHAINS, connectionStatus.completelyDown, connectionStatus.chainIds, connectionStatus.lastCheckedAt)

  proc getIsDown(message: string): bool =
    result = message == "down"

  proc getStateValue(message: string): connection_status_backend.StateValue =
    if message == "down":
      return connection_status_backend.StateValue.Disconnected
    elif message == "up":
      return connection_status_backend.StateValue.Connected
    else:
      return connection_status_backend.StateValue.Unknown

  proc getChainStatusTable(message: string): ConnectionStatusNotification =
    result = initCustomStatusNotification()

    let chainStatusTable = parseJson(message)
    if chainStatusTable.kind != JNull:
      for k, v in chainStatusTable.pairs:
        result[k] = connection_status_backend.initConnectionState(
          value = getStateValue(v.getStr)
        )

  proc getChainIdsDown(self: Service, chainStatusTable: ConnectionStatusNotification): (bool, bool, seq[int], int) =
    var allKnown: bool = true
    var allDown: bool = true
    var chaindIdsDown: seq[int] = @[]
    var lastSuccessAt: int = connection_status_backend.INVALID_TIMESTAMP # latest succesful connectinon between the down chains

    let allChainIds = self.networkService.getNetworks().map(a => a.chainId)
    for id in allChainIds:
      if chainStatusTable.hasKey($id) and chainStatusTable[$id].value != connection_status_backend.StateValue.Unknown:
        if chainStatusTable[$id].value == connection_status_backend.StateValue.Connected:
          allDown = false
        else:
          chaindIdsDown.add(id)
          lastSuccessAt = max(lastSuccessAt, chainStatusTable[$id].lastSuccessAt)
      else:
        allKnown = false

    return (allKnown, allDown, chaindIdsDown, lastSuccessAt)

  proc getFormattedStringForChainIds(self: Service, chainIds: seq[int]): string =
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
      lastCheckedAt: connectionStatus.lastCheckedAt
      )

  proc resetConnectionStatus(self: Service, website: string) =
    self.connectionStatus[website] = newConnectionStatus()

  proc updateConnectionStatus(self: Service,
    website: string,
    connectionState: ConnectionState,
    completelyDown: bool,
    chainIds: seq[int],
    lastCheckedAt: int
    ) =
      if self.connectionStatus.hasKey(website):
        self.connectionStatus[website].connectionState = connectionState
        self.connectionStatus[website].completelyDown = completelyDown
        self.connectionStatus[website].chainIds = chainIds
        self.connectionStatus[website].lastCheckedAt = lastCheckedAt

  proc updateSimpleStatus(self: Service, website: string, isDown: bool, at: int) =
    if self.connectionStatus.hasKey(website):
      if isDown:
        # trigger event
        self.updateConnectionStatus(website, ConnectionState.Failed, true, @[], at)
        self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(website, self.connectionStatus[website]))
      else:
        # if site was completely down and is back up now, trigger event
        if self.connectionStatus[website].completelyDown:
          self.connectionStatus[website] = newConnectionStatus()
          self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(website, self.connectionStatus[website]))

  proc updateMultichainStatus(self: Service, website: string, completelyDown: bool, chaindIdsDown: seq[int], at: int) =
    if self.connectionStatus.hasKey(website):
      # if all the networks are down for the website, trigger event
      if completelyDown:
        self.updateConnectionStatus(website, ConnectionState.Failed, true, chaindIdsDown, at)
        self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(website, self.connectionStatus[website]))
      # if all the networks are not down for the website
      else:
        # case where a down website is back up
        if self.connectionStatus[website].completelyDown or (chaindIdsDown.len == 0 and self.connectionStatus[website].chainIds.len != 0):
          self.resetConnectionStatus(website)
          self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(website, self.connectionStatus[website]))

        # case where a some of networks on the website are down, trigger event
        if chaindIdsDown.len > 0:
          self.updateConnectionStatus(website, ConnectionState.Failed, false, chaindIdsDown, at)
          self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(website, self.connectionStatus[website]))

  proc blockchainsRetry*(self: Service) {.slot.} =
    if(self.connectionStatus.hasKey(BLOCKCHAINS)):
      self.connectionStatus[BLOCKCHAINS].connectionState = ConnectionState.Retrying
      self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(BLOCKCHAINS, self.connectionStatus[BLOCKCHAINS]))
      self.walletService.reloadAccountTokens()

  proc marketRetry*(self: Service) {.slot.} =
    if(self.connectionStatus.hasKey(MARKET)):
      self.connectionStatus[MARKET].connectionState = ConnectionState.Retrying
      self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(MARKET, self.connectionStatus[MARKET]))
      # TODO: remove once market values are removed from tokenService
      self.walletService.reloadAccountTokens()
      self.tokenService.rebuildMarketData()

  proc collectiblesRetry*(self: Service) {.slot.} =
    if(self.connectionStatus.hasKey(COLLECTIBLES)):
      self.connectionStatus[COLLECTIBLES].connectionState = ConnectionState.Retrying
      self.events.emit(SIGNAL_CONNECTION_UPDATE, self.convertConnectionStatusToNetworkConnectionsArgs(COLLECTIBLES, self.connectionStatus[COLLECTIBLES]))
      discard collectibles_backend.refetchOwnedCollectibles()

  proc networkConnected*(self: Service, connected: bool) =
    if connected:
      self.walletService.reloadAccountTokens()
      self.tokenService.rebuildMarketData()
      discard collectibles_backend.refetchOwnedCollectibles()
    else:
      if(self.connectionStatus.hasKey(BLOCKCHAINS)):
        self.connectionStatus[BLOCKCHAINS] = newConnectionStatus()
      if(self.connectionStatus.hasKey(MARKET)):
        self.connectionStatus[MARKET] = newConnectionStatus()
      if(self.connectionStatus.hasKey(COLLECTIBLES)):
        self.connectionStatus[COLLECTIBLES] = newConnectionStatus()

  proc checkIfConnected*(self: Service, website: string): bool =
    if self.connectionStatus.hasKey(website) and self.connectionStatus[website].completelyDown:
      return false
    return true
