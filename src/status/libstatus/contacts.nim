import json, strmisc
import core, ../utils, ../types

# this module is made stateless intentionally
# all caching logic is done in status/contacts.nim

proc blockContact*(id: string, ensVerified: bool, ensName: string, alias: string, identicon: string, systemTags: seq[string], localNickname: string): string =
  callPrivateRPC("blockContact".prefix, %* [
    {
      "id": id,
      "ensVerified": ensVerified,
      "alias": alias,
      "identicon": identicon,
      "systemTags": systemTags,
      "localNickname": localNickname
    }
  ])

proc getContactByID*(id: string): string =
  callPrivateRPC("getContactByID".prefix, %* [id])

proc getContacts*(): JsonNode =
  let response = callPrivateRPC("contacts".prefix, %* []).parseJson
  if response["result"].kind == JNull:
    result = %* []
  else:
    result = response["result"]

proc saveContact*(id: string, ensVerified: bool, ensName: string, alias: string, identicon: string, thumbnail: string, systemTags: seq[string], localNickname: string): string =
  callPrivateRPC("saveContact".prefix, %* [
    {
      "id": id,
      "name": ensName,
      "ensVerified": ensVerified,
      "alias": alias,
      "identicon": identicon,
      "images": {"thumbnail": {"Payload": thumbnail.partition(",")[2]}},
      "systemTags": systemTags,
      "localNickname": localNickname
    }
  ])

proc requestContactUpdate*(publicKey: string): string =
  callPrivateRPC("sendContactUpdate".prefix, %* [publicKey, "", ""])
