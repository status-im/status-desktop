import nimqml, json, sequtils, chronicles, strutils

import backend/collectibles as backend

import app/core/eventemitter
import app/core/tasks/threadpool
import app/core/signals/types

logScope:
  topics = "collectible-service"

# Signals which may be emitted by this service:
const SIGNAL_COLLECTIBLE_PREFERENCES_UPDATED* = "collectiblePreferencesUpdated"

type
  ResultArgs* = ref object of Args
    success*: bool

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool

  proc init*(self: Service) =
    discard

  proc getCollectiblePreferences*(self: Service): JsonNode =
    try:
      let response = backend.getCollectiblePreferences()
      if not response.error.isNil:
        error "status-go error", procName="getCollectiblePreferences", errCode=response.error.code, errDesription=response.error.message
        return
      return response.result
    except Exception as e:
      error "error: ", procName="getCollectiblePreferences", errName=e.name, errDesription=e.msg

  proc updateCollectiblePreferences*(self: Service, collectiblePreferencesJson: string) =
    var updated = false
    try:
      let preferencesJson = parseJson(collectiblePreferencesJson)
      var collectiblePreferences: seq[CollectiblePreferences]
      if preferencesJson.kind == JArray:
        for preferences in preferencesJson:
          add(collectiblePreferences, fromJson(preferences, CollectiblePreferences))
      let response = backend.updateCollectiblePreferences(collectiblePreferences)
      if not response.error.isNil:
        raise newException(CatchableError, response.error.message)
      updated = true
    except Exception as e:
      error "error: ", procName="updateCollectiblePreferences", errName=e.name, errDesription=e.msg

    self.events.emit(SIGNAL_COLLECTIBLE_PREFERENCES_UPDATED, ResultArgs(success: updated))
