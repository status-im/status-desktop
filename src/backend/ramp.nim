import json

import ./core as core
import ./response_type
export response_type

import ../app_service/service/ramp/dto

proc fetchCryptoRampProviders*(): RpcResponse[JsonNode] =
  result = core.callPrivateRPC("wallet_getCryptoOnRamps", %*[])

proc fetchCryptoRampUrl*(
    providerID: string, parameters: CryptoRampParametersDto
): RpcResponse[JsonNode] =
  let payload = %*[providerID, parameters]
  result = core.callPrivateRPC("wallet_getCryptoOnRampURL", payload)
