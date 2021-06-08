import json, json_serialization

import 
  sugar, sequtils, strutils, atomics

import libstatus/mailservers as status_mailservers
import ../eventemitter
import signals/types

#TODO: temporary?
import types as LibStatusTypes

type
    MailserversModel* = ref object
        events*: EventEmitter

proc newMailserversModel*(events: EventEmitter): MailserversModel =
  result = MailserversModel()
  result.events = events

proc fillGaps*(self: MailserversModel, chatId: string, messageIds: seq[string]): string =
  result = status_mailservers.fillGaps(chatId, messageIds)
