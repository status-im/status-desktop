import json, sequtils, chronicles
import status/statusgo_backend_new/custom_tokens as custom_tokens

import ./service_interface, ./dto, ./static_token

export service_interface

logScope:
  topics = "token-service"

type 
  Service* = ref object of ServiceInterface
    tokens: seq[Dto]

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.tokens = @[]

method init*(self: Service) =
  try:
    let response = custom_tokens.getCustomTokens()

    self.tokens = concat(
      static_token.all(),
      map(response.result.getElems(), proc(x: JsonNode): Dto = x.toDto())
    )
    
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getTokens*(self: Service, chainId: int): seq[Dto] =
  return self.tokens.filter(proc(x: Dto): bool = x.chainId == chainId)
