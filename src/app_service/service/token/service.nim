import NimQml, Tables, json, sequtils, chronicles, strformat, strutils

from sugar import `=>`
import web3/ethtypes
from web3/conversions import `$`
import ../../../backend/custom_tokens as custom_tokens
import ../../../backend/tokens as token_backend

import ../settings/service_interface as settings_service
import ../network/service_interface as network_service

import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ./dto

export dto

logScope:
  topics = "token-service"

include async_tasks

const DEFAULT_VISIBLE_TOKENS = {1: @["SNT"], 3: @["STT"], 4: @["STT"]}.toTable()
# Signals which may be emitted by this service:
const SIGNAL_TOKEN_DETAILS_LOADED* = "tokenDetailsLoaded"

type
  TokenDetailsLoadedArgs* = ref object of Args
    tokenDetails*: string

type
  CustomTokenAdded* = ref object of Args
    token*: TokenDto

type
  CustomTokenRemoved* = ref object of Args
    token*: TokenDto

type
  VisibilityToggled* = ref object of Args
    token*: TokenDto

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    settingsService: settings_service.ServiceInterface
    networkService: network_service.ServiceInterface
    tokens: Table[NetworkDto, seq[TokenDto]]

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    settingsService: settings_service.ServiceInterface,
    networkService: network_service.ServiceInterface,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.settingsService = settingsService
    result.networkService = networkService
    result.tokens = initTable[NetworkDto, seq[TokenDto]]()

  proc init*(self: Service) =
    try:
      var activeTokenSymbols = self.settingsService.getWalletVisibleTokens()
      let networks = self.networkService.getEnabledNetworks()
      let responseCustomTokens = custom_tokens.getCustomTokens()

      for network in networks:
        if not activeTokenSymbols.hasKey(network.chainId):
          activeTokenSymbols[network.chainId] = DEFAULT_VISIBLE_TOKENS[network.chainId]

        let responseTokens = token_backend.getTokens(network.chainId)
        let default_tokens = map(
          responseTokens.result.getElems(), 
          proc(x: JsonNode): TokenDto = x.toTokenDto(activeTokenSymbols[network.chainId], hasIcon=true, isCustom=false)
        )

        self.tokens[network] = concat(
          default_tokens,
          map(responseCustomTokens.result.getElems(), proc(x: JsonNode): TokenDto = x.toTokenDto(activeTokenSymbols[network.chainId]))
        ).filter(
          proc(x: TokenDto): bool = x.chainId == network.chainId
        )

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc getTokens*(self: Service, useCache: bool = true): Table[NetworkDto, seq[TokenDto]] =
    if not useCache:
      self.init()

    return self.tokens

  proc getVisibleTokens*(self: Service): seq[TokenDto] =
    for tokens in self.getTokens().values:
      for token in tokens:
        if token.isVisible:
          result.add(token)

  proc addCustomToken*(self: Service, chainId: int, address: string, name: string, symbol: string, decimals: int) =
    # TODO(alaile): use chainId rather than first enabled network
    let networkWIP = self.networkService.getEnabledNetworks()[0]
    custom_tokens.addCustomToken(networkWIP.chainId, address, name, symbol, decimals, "")
    let token = newDto(
      name,
      networkWIP.chainId,
      fromHex(Address, address),
      symbol,
      decimals,
      false,
      true
    )
    let network = self.networkService.getNetwork(networkWIP.chainId)
    self.tokens[network].add(token)
    self.events.emit("token/customTokenAdded", CustomTokenAdded(token: token))

  proc toggleVisible*(self: Service, chainId: int, symbol: string) =
    let network = self.networkService.getNetwork(chainId)
    var tokenChanged = self.tokens[network][0]
    for token in self.tokens[network]:
      if token.symbol == symbol:
        token.isVisible = not token.isVisible
        tokenChanged = token
        break
      
    var visibleSymbols = initTable[int, seq[string]]()
    for network, tokens in self.tokens.pairs:
      let symbols = tokens.filter(t => t.isVisible).map(t => t.symbol)
      visibleSymbols[network.chainId] = symbols

    discard self.settingsService.saveWalletVisibleTokens(visibleSymbols)
    self.events.emit("token/visibilityToggled", VisibilityToggled(token: tokenChanged))

  proc removeCustomToken*(self: Service, chainId: int, address: string) =
    let network = self.networkService.getNetwork(chainId)
    custom_tokens.removeCustomToken(chainId, address)
    var index = -1

    for idx, token in self.tokens[network].pairs():
      if $token.address == address:
        index = idx
        break

    let tokenRemoved = self.tokens[network][index]
    self.tokens[network].del(index)
    self.events.emit("token/customTokenRemoved", CustomTokenRemoved(token: tokenRemoved))

  proc tokenDetailsResolved*(self: Service, tokenDetails: string) {.slot.} =
    self.events.emit(SIGNAL_TOKEN_DETAILS_LOADED, TokenDetailsLoadedArgs(
      tokenDetails: tokenDetails
    ))
    
  proc getTokenDetails*(self: Service, chainId: int, address: string) =
    let arg = GetTokenDetailsTaskArg(
      tptr: cast[ByteAddress](getTokenDetailsTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "tokenDetailsResolved",
      chainId: chainId,
      address: address
    )
    self.threadpool.start(arg)
