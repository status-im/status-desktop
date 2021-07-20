import json

import libstatus/mailservers as status_mailservers
import ../eventemitter

type
    MailserversModel* = ref object
        events*: EventEmitter

proc newMailserversModel*(events: EventEmitter): MailserversModel =
  result = MailserversModel()
  result.events = events

proc fillGaps*(self: MailserversModel, chatId: string, messageIds: seq[string]): string =
  result = status_mailservers.fillGaps(chatId, messageIds)
