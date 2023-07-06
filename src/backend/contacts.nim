import json
import core, ../app_service/common/utils
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

proc acceptContactRequest*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
      "id": id
    }]
  result = callPrivateRPC("acceptContactRequest".prefix, payload)

proc dismissLatestContactRequestForContact*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[{
    "id": id
  }]
  result = callPrivateRPC("dismissLatestContactRequestForContact".prefix, payload)

proc declineContactRequest*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[{
    "id": id
  }]
  result = callPrivateRPC("declineContactRequest".prefix, payload)

proc sendContactUpdate*(publicKey, ensName, thumbnail: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [publicKey, ensName, thumbnail]
  result = callPrivateRPC("sendContactUpdate".prefix, payload)

proc getImageServerURL*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("imageServerURL".prefix, payload)

proc markUntrustworthy*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey]
  result = callPrivateRPC("markAsUntrustworthy".prefix, payload)

proc verifiedTrusted*(requestId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[{
    "id": requestId
  }]
  result = callPrivateRPC("verifiedTrusted".prefix, payload)

proc verifiedUntrustworthy*(requestId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[{
    "id": requestId
  }]
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

proc acceptVerificationRequest*(requestId: string, response: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [requestId, response]
  result = callPrivateRPC("acceptContactVerificationRequest".prefix, payload)

proc declineVerificationRequest*(requestId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [requestId]
  result = callPrivateRPC("declineContactVerificationRequest".prefix, payload)

proc getVerificationRequestSentTo*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey]
  result = callPrivateRPC("getVerificationRequestSentTo".prefix, payload)

proc getVerificationRequestFrom*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [pubkey]
  result = callPrivateRPC("getLatestVerificationRequestFrom".prefix, payload)

proc getReceivedVerificationRequests*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("getReceivedVerificationRequests".prefix, payload)

proc cancelVerificationRequest*(requestId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [requestId]
  result = callPrivateRPC("cancelVerificationRequest".prefix, payload)

proc retractContactRequest*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[{
    "id": pubkey
  }]
  result = callPrivateRPC("retractContactRequest".prefix, payload)

proc requestContactInfo*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("requestContactInfoFromMailserver".prefix, %*[pubkey])

proc shareUserUrlWithData*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("shareUserURLWithData".prefix, %*[pubkey])

proc shareUserUrlWithChatKey*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("shareUserURLWithChatKey".prefix, %*[pubkey])

proc shareUserUrlWithENS*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("shareUserURLWithENS".prefix, %*[pubkey])