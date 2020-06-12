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
