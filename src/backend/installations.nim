import json
import core, ../app_service/common/utils
import response_type

export response_type

proc setInstallationMetadata*(installationId: string, deviceName: string, deviceType: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [installationId, {
    "name": deviceName,
    "deviceType": deviceType
  }]
  result = callPrivateRPC("setInstallationMetadata".prefix, payload)

proc setInstallationName*(installationId: string, name: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [installationId, name]
  result = callPrivateRPC("setInstallationName".prefix, payload)

proc getOurInstallations*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("getOurInstallations".prefix, payload)

proc syncDevices*(preferredName: string, photoPath: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [preferredName, photoPath]
  result = callPrivateRPC("syncDevices".prefix, payload)

proc sendPairInstallation*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("sendPairInstallation".prefix)

proc enableInstallation*(installationId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [installationId]
  result = callPrivateRPC("enableInstallation".prefix, payload)

proc disableInstallation*(installationId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [installationId]
  result = callPrivateRPC("disableInstallation".prefix, payload)
