import json, strmisc, atomics
import core, utils, types, settings
from ../profile/profile import Profile

var
  contacts {.threadvar.}: JsonNode
  contactsInited {.threadvar.}: bool
  dirty: Atomic[bool]

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
  dirty.store(true)

proc getContacts*(): JsonNode =
  let cacheIsDirty = (not contactsInited) or dirty.load
  if not cacheIsDirty:
    result = contacts
  else:
    let payload = %* []
    let response = callPrivateRPC("contacts".prefix, payload).parseJson
    if response["result"].kind == JNull:
      result = %* []
    else:
      result = response["result"]
    dirty.store(false)
    contacts = result
    contactsInited = true

proc saveContact*(id: string, ensVerified: bool, ensName: string, alias: string, identicon: string, thumbnail: string, systemTags: seq[string], localNickname: string): string =
  let payload = %* [{
      "id": id,
      "name": ensName,
      "ensVerified": ensVerified,
      "alias": alias,
      "identicon": identicon,
      "images": {"thumbnail": {"Payload": thumbnail.partition(",")[2]}},
      "systemTags": systemTags,
      "localNickname": localNickname
    }]
  # TODO: StatusGoError handling
  result = callPrivateRPC("saveContact".prefix, payload)
  dirty.store(true)

proc requestContactUpdate*(publicKey: string): string =
  result = callPrivateRPC("sendContactUpdate".prefix, %* [publicKey, "", ""])
  dirty.store(true)

proc ensVerified*(publicKey: string, ensName: string): string =
  result = callPrivateRPC("ensVerified".prefix, %* [publicKey, ensName])
  dirty.store(true)
