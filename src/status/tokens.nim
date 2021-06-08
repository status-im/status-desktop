import json, json_serialization

import 
  sugar, sequtils, strutils, atomics

import libstatus/tokens as status_tokens
import ../eventemitter
import signals/types

#TODO: temporary?
import types as LibStatusTypes

type
    TokensModel* = ref object
        events*: EventEmitter

proc newTokensModel*(events: EventEmitter): TokensModel =
  result = TokensModel()
  result.events = events

proc getSNTAddress*(): string =
  result = status_tokens.getSNTAddress()

proc getSNTBalance*(account: string): string =
  result = status_tokens.getSNTBalance(account)

