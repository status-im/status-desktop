import NimQml, chronicles, json, strutils, sequtils, tables, times

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
    notifExemptionsCache: Table[string, NotificationsExemptions]

    proc delete*(self: Service) =
      self.QObject.delete

    proc newService*(events: EventEmitter): Service =
      new(result, delete)
      result.events = events
      result.QObject.setup

    proc init*(self: Service) =
      let response = status_kvstore.getKvstoreConfigs()
      self.kvstore = response.result.toKvstoreDto()

    proc saveRateLimitEnabled*(self: Service, value: bool): bool =
      if(self.save)
