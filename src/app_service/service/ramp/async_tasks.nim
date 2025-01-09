import json
import backend/ramp as ramp_backend

proc getCryptoServicesTask*(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[QObjectTaskArg](argEncoded)

  try:
    let response = ramp_backend.fetchCryptoRampProviders()

    if not response.error.isNil:
      raise newException(
        ValueError, "Error fetching crypto services" & response.error.message
      )

    arg.finish(%*{"result": response.result})
  except Exception as e:
    error "Error fetching crypto services", message = e.msg
    arg.finish(%*{"result": @[]})

type GetCryptoRampUrlTaskArg* = ref object of QObjectTaskArg
  uuid: string
  providerID: string
  parameters: JsonNode

proc getCryptoRampUrlTask*(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetCryptoRampUrlTaskArg](argEncoded)

  var data = %*{"uuid": arg.uuid}

  try:
    let parameters = fromJson(arg.parameters, CryptoRampParametersDto)
    let response = ramp_backend.fetchCryptoRampUrl(arg.providerID, parameters)

    if not response.error.isNil:
      raise newException(
        ValueError, "Error fetching crypto ramp url" & response.error.message
      )
    data["url"] = response.result
    arg.finish(data)
  except Exception as e:
    error "Error fetching crypto ramp url", message = e.msg
    arg.finish(data)
