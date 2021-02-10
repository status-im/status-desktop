import json
import core, utils, types, settings
from ../profile/profile import Profile

# TODO: remove Profile from here
proc blockContact*(contact: Profile): string =
  callPrivateRPC("blockContact".prefix, %* [
    {
      "id": contact.id,
      "ensVerified": contact.ensVerified,
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

proc saveContact*(id: string, ensVerified: bool, ensName: string, alias: string, identicon: string, systemTags: seq[string], localNickname: string): string =
  let payload = %* [{
      "id": id,
      "name": ensName,
      "ensVerified": ensVerified,
      "alias": alias,
      "identicon": identicon,
      "systemTags": systemTags,
      "localNickname": localNickname
    }]
  callPrivateRPC("saveContact".prefix, payload)

proc requestContactUpdate*(publicKey: string): string =
  callPrivateRPC("sendContactUpdate".prefix, %* [publicKey, "", ""])