import NimQml, chronicles, json, strutils, sequtils, tables

import app/core/eventemitter
import backend/kvstore as status_kvstore

import ./dto
export dto

logScope:
  topics = "kvstore-service"

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    kvstore: KvstoreDto

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter): Service =
    new(result, delete)
    result.events = events
    result.QObject.setup

  proc init*(self: Service) =
    let response = status_kvstore.getStoreEntry()
    self.kvstore = response.result.toKvstoreDto()
  
  proc isRlnRateLimitEnabled*(self: Service): bool =
    return self.kvstore.rlnRateLimitEnabled

  proc setRlnRateLimitEnabled*(self: Service, value: bool): bool =
    let response = status_kvstore.setRlnRateLimitEnabled(value)
    if (not response.error.isNil):
      error "error set rate limit: ", errDescription = response.error.message
      return false
    self.kvstore.rlnRateLimitEnabled = value
    return true
