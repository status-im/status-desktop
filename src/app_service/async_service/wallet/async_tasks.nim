include status/utils/json_utils

#################################################
# Async request for the list of services to buy/sell crypto
#################################################

const asyncGetCryptoServicesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[QObjectTaskArg](argEncoded)
  var success: bool
  let response = status_wallet.fetchCryptoServices(success)

  var list: JsonNode
  if(success):
    list = response.parseJson()["result"]

  arg.finish($list)