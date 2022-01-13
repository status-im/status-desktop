import httpclient
import json
import strformat
import os
import uri
import chronicles
import sequtils

import ../settings/service_interface as settings_service
import ./dto
import ./service_interface

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

const baseUrl = "https://g.tenor.com/v1/"
let defaultParams = fmt("&media_filter=minimal&limit=50&key={TENOR_API_KEY_RESOLVED}")

type
  Service* = ref object of service_interface.ServiceInterface
    settingsService: settings_service.ServiceInterface
    client: HttpClient
    favorites: seq[GifDto]
    recents: seq[GifDto]
    favoritesLoaded: bool
    recentsLoaded: bool

method delete*(self: Service) =
  discard

proc newService*(settingsService: settings_service.ServiceInterface): Service =
  result = Service()
  result.settingsService = settingsService
  result.client = newHttpClient()
  result.favorites = @[]
  result.recents = @[]

proc setFavoriteGifs(self: Service, gifDtos: seq[GifDto]) =
  let node = %*{"items": map(gifDtos, toJsonNode)}
  discard self.settingsService.saveGifFavorites(node)

proc setRecentGifs(self: Service, gifDtos: seq[GifDto]) =
  let node = %*{"items": map(gifDtos, toJsonNode)}
  discard self.settingsService.saveGifRecents(node)

proc getContentWithRetry(self: Service, path: string, maxRetry: int = 3): string =
  var currentRetry = 0
  while true:
    try:
      let content = self.client.getContent(fmt("{baseUrl}{path}{defaultParams}"))
      return content
    except Exception as e:
      currentRetry += 1
      error "could not query tenor API", msg=e.msg

      if currentRetry >= maxRetry:
        raise

      sleep(100 * currentRetry)

proc tenorQuery(self: Service, path: string): seq[GifDto] =
  try:
    let content = self.getContentWithRetry(path)
    let doc = content.parseJson()

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

proc getFavorites*(self: Service): seq[GifDto] =
  if not self.favoritesLoaded:
    self.favoritesLoaded = true
    let node = self.settingsService.getGifFavorites()
    self.favorites = map(node{"items"}.getElems(), settingToGifDto)

  return self.favorites

proc getRecents*(self: Service): seq[GifDto] =
  if not self.recentsLoaded:
    self.recentsLoaded = true
    let node = self.settingsService.getGifRecents()
    self.recents = map(node{"items"}.getElems(), settingToGifDto)

  return self.recents

proc isFavorite*(self: Service, gifDto: GifDto): bool =
  for favorite in self.getFavorites():
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
  self.setFavoriteGifs(newFavorites)

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
  self.setRecentGifs(newRecents)