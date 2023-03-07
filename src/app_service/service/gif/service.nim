import json
import strformat
import os
import uri
import chronicles
import sequtils
import NimQml

import ../settings/service as settings_service
import ../../../app/core/eventemitter
import ../../../backend/backend
import ../../../app/core/tasks/[qt, threadpool]
import ../../../app/core/[main]
import ./dto

include ./async_tasks

logScope:
  topics = "gif-service"

const MAX_RECENT = 50
# set via `nim c` param `-d:TENOR_API_KEY:[api_key]`; should be set in CI/release builds
const TENOR_API_KEY {.strdefine.} = ""
let TENOR_API_KEY_ENV = $getEnv("TENOR_API_KEY")

let TENOR_API_KEY_RESOLVED =
  if TENOR_API_KEY_ENV != "":
    TENOR_API_KEY_ENV
  else:
    TENOR_API_KEY

const SIGNAL_LOAD_RECENT_GIFS_STARTED* = "loadRecentGifsStarted"
const SIGNAL_LOAD_RECENT_GIFS_DONE* = "loadRecentGifsDone"

const SIGNAL_LOAD_FAVORITE_GIFS_STARTED* = "loadFavoriteGifsStarted"
const SIGNAL_LOAD_FAVORITE_GIFS_DONE* = "loadFavoriteGifsDone"

type
  GifsArgs* = ref object of Args
    gifs*: seq[GifDto]
    error*: string

QtObject:
  type
    Service* = ref object of QObject
      threadpool: ThreadPool
      settingsService: settings_service.Service
      favorites: seq[GifDto]
      recents: seq[GifDto]
      events: EventEmitter

  proc delete*(self: Service) =
    discard

  proc newService*(settingsService: settings_service.Service, events: EventEmitter, threadpool: ThreadPool): Service =
    result = Service()
    result.QObject.setup
    result.settingsService = settingsService
    result.events = events
    result.threadpool = threadpool
    result.favorites = @[]
    result.recents = @[]

  proc setTenorAPIKey(self: Service) =
    try:
      let response = backend.setTenorAPIKey(TENOR_API_KEY_RESOLVED)
      if(not response.error.isNil):
        error "error setTenorAPIKey: ", errDescription = response.error.message

    except Exception as e:
      error "error: ", procName="setTenorAPIKey", errName = e.name, errDesription = e.msg

  proc getRecentGifs(self: Service) =
    try:
      let response = backend.getRecentGifs()

      if(not response.error.isNil):
        error "error getRecentGifs: ", errDescription = response.error.message

      self.recents = map(response.result.getElems(), settingToGifDto)

    except Exception as e:
      error "error: ", procName="getRecentGifs", errName = e.name, errDesription = e.msg

  proc getFavoriteGifs(self: Service) =
    try:
      let response = backend.getFavoriteGifs()

      if(not response.error.isNil):
        error "error getFavoriteGifs: ", errDescription = response.error.message

      self.favorites = map(response.result.getElems(), settingToGifDto)

    except Exception as e:
      error "error: ", procName="getFavoriteGifs", errName = e.name, errDesription = e.msg

  proc asyncLoadRecentGifs*(self: Service) =
    self.events.emit(SIGNAL_LOAD_RECENT_GIFS_STARTED, Args())
    try:
      let arg = AsyncGetRecentGifsTaskArg(
        tptr: cast[ByteAddress](asyncGetRecentGifsTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onAsyncGetRecentGifsDone"
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading recent gifs", msg = e.msg

  proc onAsyncGetRecentGifsDone*(self: Service, response: string) {.slot.} =
    try:
      let rpcResponseObj = response.parseJson
      if (rpcResponseObj{"error"}.kind != JNull):
        let error = Json.decode($rpcResponseObj["error"], RpcError)
        error "error loading recent gifs", msg = error.message
        return

      self.recents = map(rpcResponseObj{"result"}.getElems(), settingToGifDto)
      self.events.emit(SIGNAL_LOAD_RECENT_GIFS_DONE, GifsArgs(gifs: self.recents))
    except Exception as e:
      let errMsg = e.msg
      error "error: ", errMsg

  proc asyncLoadFavoriteGifs*(self: Service) =
    self.events.emit(SIGNAL_LOAD_FAVORITE_GIFS_STARTED, Args())
    try:
      let arg = AsyncGetFavoriteGifsTaskArg(
        tptr: cast[ByteAddress](asyncGetFavoriteGifsTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onAsyncGetFavoriteGifsDone"
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading favorite gifs", msg = e.msg

  proc onAsyncGetFavoriteGifsDone*(self: Service, response: string) {.slot.} =
    try:
      let rpcResponseObj = response.parseJson
      if (rpcResponseObj{"error"}.kind != JNull):
        let error = Json.decode($rpcResponseObj["error"], RpcError)
        error "error loading favorite gifs", msg = error.message
        return

      self.favorites = map(rpcResponseObj{"result"}.getElems(), settingToGifDto)
      self.events.emit(SIGNAL_LOAD_FAVORITE_GIFS_DONE, GifsArgs(gifs: self.favorites))
    except Exception as e:
      let errMsg = e.msg
      error "error: ", errMsg

  proc init*(self: Service) =
    # set Tenor API Key
    self.setTenorAPIKey()

  proc tenorQuery(self: Service, path: string): seq[GifDto] =
    try:
      let response = backend.fetchGifs(path)
      let doc = response.result.str.parseJson()

      var items: seq[GifDto] = @[]
      for json in doc["results"]:
        items.add(tenorToGifDto(json))

      return items
    except:
      return @[]

  proc search*(self: Service, query: string): seq[GifDto] =
    return self.tenorQuery(fmt("search?q={encodeUrl(query)}"))

  proc getTrendings*(self: Service): seq[GifDto] =
    return self.tenorQuery("trending?")

  proc getRecents*(self: Service): seq[GifDto] =
    return self.recents

  proc addToRecents*(self: Service, gifDto: GifDto) =
    let recents = self.getRecents()
    var newRecents: seq[GifDto] = @[gifDto]
    var idx = 0

    while idx < MAX_RECENT - 1:
      if idx >= recents.len:
        break

      if recents[idx].id == gifDto.id:
        idx += 1
        continue

      newRecents.add(recents[idx])
      idx += 1

    self.recents = newRecents
    let recent = %*{"items": map(newRecents, toJsonNode)}
    discard backend.updateRecentGifs(recent)

  proc getFavorites*(self: Service): seq[GifDto] =
    return self.favorites

  proc isFavorite*(self: Service, gifDto: GifDto): bool =
    for favorite in self.favorites:
      if favorite.id == gifDto.id:
        return true
    return false

  proc toggleFavorite*(self: Service, gifDto: GifDto) =
    var newFavorites: seq[GifDto] = @[]
    var found = false

    for favoriteGif in self.getFavorites():
      if favoriteGif.id == gifDto.id:
        found = true
        continue

      newFavorites.add(favoriteGif)

    if not found:
      newFavorites.add(gifDto)

    self.favorites = newFavorites
    let favorites = %*{"items": map(newFavorites, toJsonNode)}
    discard backend.updateFavoriteGifs(favorites)
