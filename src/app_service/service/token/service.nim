import json, sequtils, chronicles
import status/statusgo_backend_new/custom_tokens as custom_tokens
import ../setting/service as setting_service

import ./service_interface, ./dto, ./static_token

export service_interface

logScope:
  topics = "token-service"

const DEFAULT_VISIBLE_SYMBOLS = @["SNT"]

type 
  Service* = ref object of service_interface.ServiceInterface
    settingService: setting_service.ServiceInterface
    tokens: seq[TokenDto]

method delete*(self: Service) =
  discard

proc newService*(settingService: setting_service.Service): Service =
  result = Service()
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
