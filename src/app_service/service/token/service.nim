import json, sequtils, chronicles
import eventemitter
from sugar import `=>`
import web3/ethtypes
from web3/conversions import `$`
import status/statusgo_backend_new/custom_tokens as custom_tokens
import ../setting/service as setting_service

import ./service_interface, ./dto, ./static_token

export service_interface

logScope:
  topics = "token-service"

const DEFAULT_VISIBLE_SYMBOLS = @["SNT"]

type 
  CustomTokenAdded* = ref object of Args
    token*: TokenDto

type 
  CustomTokenRemoved* = ref object of Args
    token*: TokenDto

type
  VisibilityToggled* = ref object of Args
    token*: TokenDto

type
  Service* = ref object of service_interface.ServiceInterface
    events: EventEmitter
    settingService: setting_service.Service
    tokens: seq[TokenDto]

method delete*(self: Service) =
  discard

proc newService*(events: EventEmitter, settingService: setting_service.Service): Service =
  result = Service()
  result.events = events
  result.settingService = settingService
  result.tokens = @[]

method init*(self: Service) =
  try:
    var activeTokenSymbols = self.settingService.getSetting().activeTokenSymbols
    if activeTokenSymbols.len == 0:
      activeTokenSymbols = DEFAULT_VISIBLE_SYMBOLS

    let static_tokens = static_token.all().map(
      proc(x: TokenDto): TokenDto =
        x.isVisible = activeTokenSymbols.contains(x.symbol)
        return x
    )

    let response = custom_tokens.getCustomTokens()
    self.tokens = concat(
      static_tokens,
      map(response.result.getElems(), proc(x: JsonNode): TokenDto = x.toTokenDto(activeTokenSymbols))
    ).filter(
      proc(x: TokenDto): bool = x.chainId == self.settingService.getSetting().currentNetwork.id
    )

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getTokens*(self: Service): seq[TokenDto] =
  return self.tokens

method addCustomToken*(self: Service, address: string, name: string, symbol: string, decimals: int) =
  custom_tokens.addCustomToken(address, name, symbol, decimals, "")
  let token = newDto(
    name,
    self.settingService.getSetting().currentNetwork.id,
    fromHex(Address, address),
    symbol,
    decimals,
    false,
    true
  )
  self.tokens.add(token)
  self.events.emit("token/customTokenAdded", CustomTokenAdded(token: token))

method toggleVisible*(self: Service, symbol: string) =
  var tokenChanged = self.tokens[0]
  for token in self.tokens:
    if token.symbol == symbol:
      token.isVisible = not token.isVisible
      tokenChanged = token
      break

  let visibleSymbols = self.tokens.filter(t => t.isVisible).map(t => t.symbol)
  discard self.settingService.saveSetting("wallet/visible-tokens", visibleSymbols)
  self.events.emit("token/visibilityToggled", VisibilityToggled(token: tokenChanged))

method removeCustomToken*(self: Service, address: string) =
  custom_tokens.removeCustomToken(address)
  var index = -1

  for idx, token in self.tokens.pairs():
    if $token.address == address:
      index = idx
      break

  let tokenRemoved = self.tokens[index]
  self.tokens.del(index)
  self.events.emit("token/customTokenRemoved", CustomTokenRemoved(token: tokenRemoved))
