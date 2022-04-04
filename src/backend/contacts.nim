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
  result = callPrivateRPC("blockContact".prefix, %* [id])

proc unblockContact*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("unblockContact".prefix, %* [id])

proc removeContact*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("removeContact".prefix, %* [id])

proc rejectContactRequest*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[{
    "id": id
  }]
  result = callPrivateRPC("rejectContactRequest".prefix, payload)

proc setContactLocalNickname*(id: string, name: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
    "id": id,
    "nickname": name
  }]
  result = callPrivateRPC("setContactLocalNickname".prefix, payload)

proc addContact*(id: string, ensName: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
      "id": id,
      "ensName": ensName
    }]
  result = callPrivateRPC("addContact".prefix, payload)

proc sendContactUpdate*(publicKey, ensName, thumbnail: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [publicKey, ensName, thumbnail]
  result = callPrivateRPC("sendContactUpdate".prefix, payload)

proc getImageServerURL*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("imageServerURL".prefix, payload)

proc markUntrustworthy*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey]
  result = callPrivateRPC("markAsUntrustworthy".prefix, payload)

proc verifiedTrusted*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey]
  result = callPrivateRPC("verifiedTrusted".prefix, payload)

proc verifiedUntrustworthy*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey]
  result = callPrivateRPC("verifiedUntrustworthy".prefix, payload)

proc removeTrustStatus*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey]
  result = callPrivateRPC("removeTrustStatus".prefix, payload)

proc getTrustStatus*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey]
  result = callPrivateRPC("getTrustStatus".prefix, payload)

proc sendVerificationRequest*(pubkey: string, challenge: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey, challenge]
  result = callPrivateRPC("sendContactVerificationRequest".prefix, payload)

proc acceptVerificationRequest*(pubkey: string, response: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey, response]
  result = callPrivateRPC("acceptContactVerificationRequest".prefix, payload)

proc declineVerificationRequest*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey]
  result = callPrivateRPC("declineContactVerificationRequest".prefix, payload)

proc getVerificationRequestSentTo*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey]
  result = callPrivateRPC("getVerificationRequestSentTo".prefix, payload)

proc getVerificationRequestFrom*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey]
  result = callPrivateRPC("getVerificationRequestFrom".prefix, payload)

proc cancelVerificationRequest*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey]
  result = callPrivateRPC("cancelVerificationRequest".prefix, payload)
