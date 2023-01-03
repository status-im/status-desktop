import NimQml, Tables, json, sequtils, chronicles, strformat, strutils

from sugar import `=>`
import web3/ethtypes
from web3/conversions import `$`
import ../../../backend/backend as backend

import ../network/service as network_service

import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ./dto

export dto

logScope:
  topics = "token-service"

include async_tasks

# Signals which may be emitted by this service:
const SIGNAL_TOKEN_HISTORICAL_DATA_LOADED* = "tokenHistoricalDataLoaded"
const SIGNAL_BALANCE_HISTORY_DATA_READY* = "tokenBalanceHistoryDataReady"

type
  TokenHistoricalDataArgs* = ref object of Args
    result*: string

type
  TokenBalanceHistoryDataArgs* = ref object of Args
    result*: string

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    networkService: network_service.Service
    tokens: Table[NetworkDto, seq[TokenDto]]

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    networkService: network_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.networkService = networkService
    result.tokens = initTable[NetworkDto, seq[TokenDto]]()

  proc init*(self: Service) =
    try:
      let networks = self.networkService.getNetworks()
    
      for network in networks:
        var found = false
        for n in self.tokens.keys:
          if n.chainId == network.chainId:
            found = true
            break

        
        if found:
          continue
        
        echo network.chainId
        let responseTokens = backend.getTokens(network.chainId)
        let default_tokens = map(
          responseTokens.result.getElems(), 
          proc(x: JsonNode): TokenDto = x.toTokenDto(network.enabled, hasIcon=true, isCustom=false)
        )

        self.tokens[network] = default_tokens.filter(
          proc(x: TokenDto): bool = x.chainId == network.chainId
        )

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc getTokens*(self: Service): Table[NetworkDto, seq[TokenDto]] =
    return self.tokens

  proc findTokenBySymbol*(self: Service, network: NetworkDto, symbol: string): TokenDto =
    try:
      for token in self.tokens[network]:
        if token.symbol == symbol:
          return token
    except Exception as e:
      error "Error finding token by symbol", msg = e.msg

  proc findTokenByAddress*(self: Service, network: NetworkDto, address: Address): TokenDto =
    for token in self.tokens[network]:
      if token.address == address:
        return token

  proc findTokenSymbolByAddress*(self: Service, address: string): string =
    if address.isEmptyOrWhitespace:
      return ""

    var hexAddressValue: Address
    try:
      hexAddressValue = fromHex(Address, address)
    except Exception as e:
      return ""

    for _, tokens in self.tokens:
      for token in tokens:
        if token.address == hexAddressValue:
          return token.symbol
    return ""

  proc tokenHistoricalDataResolved*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "prepared tokens are not a json object"
      return

    self.events.emit(SIGNAL_TOKEN_HISTORICAL_DATA_LOADED, TokenHistoricalDataArgs(
      result: response
    ))

  proc tokenBalanceHistoryDataResolved*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "blance history response is not a json object"
      return

    self.events.emit(SIGNAL_BALANCE_HISTORY_DATA_READY, TokenBalanceHistoryDataArgs(
      result: response
    ))

  proc getHistoricalDataForToken*(self: Service, symbol: string, currency: string, range: int) =
    let arg = GetTokenHistoricalDataTaskArg(
      tptr: cast[ByteAddress](getTokenHistoricalDataTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "tokenHistoricalDataResolved",
      symbol: symbol,
      currency: currency,
      range: range
    )
    self.threadpool.start(arg)

  proc fetchHistoricalBalanceForTokenAsJson*(self: Service, address: string, symbol: string, timeInterval: BalanceHistoryTimeInterval) =
    let networks = self.networkService.getNetworks()
    for network in networks:
      if network.enabled:
        let arg = GetTokenBalanceHistoryDataTaskArg(
          tptr: cast[ByteAddress](getTokenBalanceHistoryDataTask),
          vptr: cast[ByteAddress](self.vptr),
          slot: "tokenBalanceHistoryDataResolved",
          chainId: network.chainId,
          address: address,
          symbol: symbol,
          timeInterval: timeInterval
        )
        self.threadpool.start(arg)
        return
    error "faild to find a network with the symbol", symbol