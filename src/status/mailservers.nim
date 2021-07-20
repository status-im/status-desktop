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

proc setMailserver*(self: MailserversModel, peer: string): string =
  result = status_mailservers.setMailserver(peer)

proc requestAllHistoricMessages*(self: MailserversModel): string =
  result = status_mailservers.requestAllHistoricMessages()