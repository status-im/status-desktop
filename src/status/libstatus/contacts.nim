import json, strmisc
import core, utils, types, settings
from ../profile/profile import Profile

# TODO: remove Profile from here
proc blockContact*(contact: Profile): string =
  callPrivateRPC("blockContact".prefix, %* [
    {
      "id": contact.id,
      "ensVerified": contact.ensVerified,
      "ensVerifiedAt": contact.ensVerifiedAt,
      "ensVerificationRetries": contact.ensVerificationRetries,
      "alias": contact.alias,
      "identicon": contact.identicon,
      "systemTags": contact.systemTags
    }
  ])

proc getContactByID*(id: string): string =
  result = callPrivateRPC("getContactByID".prefix, %* [id])

proc getContacts*(): JsonNode =
  let payload = %* []
  let response = callPrivateRPC("contacts".prefix, payload).parseJson
  if response["result"].kind == JNull:
    return %* []
  return response["result"]

proc saveContact*(id: string, ensVerified: bool, ensName: string, ensVerifiedAt: int, ensVerificationRetries: int, alias: string, identicon: string, thumbnail: string, systemTags: seq[string], localNickname: string): string =
  let payload = %* [{
      "id": id,
      "name": ensName,
      "ensVerified": ensVerified,
      "ensVerifiedAt": ensVerifiedAt,
      "ensVerificationRetries": ensVerificationRetries,
      "alias": alias,
      "identicon": identicon,
      "images": {"thumbnail": {"Payload": thumbnail.partition(",")[2]}},
      "systemTags": systemTags,
      "localNickname": localNickname
    }]
  callPrivateRPC("saveContact".prefix, payload)

proc requestContactUpdate*(publicKey: string): string =
  callPrivateRPC("sendContactUpdate".prefix, %* [publicKey, "", ""])