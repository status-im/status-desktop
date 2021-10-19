import json, sequtils, chronicles
import status/statusgo_backend_new/custom_tokens as custom_tokens
import ../setting/service as setting_service

import ./service_interface, ./dto, ./static_token

export service_interface

logScope:
  topics = "token-service"

type 
  Service* = ref object of service_interface.ServiceInterface
    settingService: setting_service.ServiceInterface
    tokens: seq[Dto]

method delete*(self: Service) =
  discard

proc newService*(settingService: setting_service.Service): Service =
  result = Service()
  result.settingService = settingService
  result.tokens = @[]

method init*(self: Service) =
  try:
    let response = custom_tokens.getCustomTokens()
    let activeTokenSymbols = self.settingService.getSetting().activeTokenSymbols
    let static_tokens = static_token.all().map(
      proc(x: Dto): Dto = 
        x.visible = activeTokenSymbols.contains(x.symbol)
        return x
    )

    self.tokens = concat(
      static_tokens,
      map(response.result.getElems(), proc(x: JsonNode): Dto = x.toTokenDto(activeTokenSymbols))
    ).filter(
      proc(x: Dto): bool = x.chainId == self.settingService.getSetting().currentNetwork.id
    )
    
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getTokens*(self: Service): seq[Dto] =
  return self.tokens
