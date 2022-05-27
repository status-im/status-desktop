import json, strmisc
import core, utils
import response_type

export response_type

proc getContacts*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("contacts".prefix, payload)

proc getContactById*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [id]
  result = callPrivateRPC("getContactByID".prefix, payload)

proc blockContact*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("blockContactDesktop".prefix, %* [id])

proc unblockContact*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("unblockContact".prefix, %* [id])

proc removeContact*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("removeContact".prefix, %* [id])

proc setContactLocalNickname*(id: string, name: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
    "id": id,
    "nickname": name
  }]
  result = callPrivateRPC("setContactLocalNickname".prefix, payload)

proc sendContactRequest*(id: string, message: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
      "id": id,
      "message": message
    }]
  result = callPrivateRPC("sendContactRequest".prefix, payload)

proc acceptLatestContactRequestForContact*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
      "id": id
    }]
  result = callPrivateRPC("acceptLatestContactRequestForContact".prefix, payload)

proc dismissLatestContactRequestForContact*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[{
    "id": id
  }]
  result = callPrivateRPC("dismissLatestContactRequestForContact".prefix, payload)

proc sendContactUpdate*(publicKey, ensName, thumbnail: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [publicKey, ensName, thumbnail]
  result = callPrivateRPC("sendContactUpdate".prefix, payload)

proc getImageServerURL*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("imageServerURL".prefix, payload)
