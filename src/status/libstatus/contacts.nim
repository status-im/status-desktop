import core
import json
import utils
import ../profile

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
  callPrivateRPC("getContactByID".prefix, %* [id])

proc getContacts*(): JsonNode =
  let payload = %* []
  let response = callPrivateRPC("wakuext_contacts", payload).parseJson
  if response["result"].kind == JNull:
    return %* []
  return response["result"]

proc saveContact*(id: string, ensVerified: bool, ensVerifiedAt: int, ensVerificationRetries: int, alias: string, identicon: string, systemTags: seq[string]): string =
  let payload = %* [{
      "id": id,
      "ensVerified": ensVerified,
      "ensVerifiedAt": ensVerifiedAt,
      "ensVerificationRetries": ensVerificationRetries,
      "alias": alias,
      "identicon": identicon,
      "systemTags": systemTags
    }]
  callPrivateRPC("shhext_saveContact", payload)
