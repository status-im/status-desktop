import httpclient
import json
import strformat
import os
import uri
import chronicles
import sequtils

import ../settings/service_interface as settings_service
import status/gif as status_gif
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

type
  Service* = ref object of service_interface.ServiceInterface
    settingsService: settings_service.ServiceInterface
    client: HttpClient
    favorites: seq[GifDto]
    recents: seq[GifDto]

method delete*(self: Service) =
  discard

proc newService*(settingsService: settings_service.ServiceInterface): Service =
  result = Service()
  result.settingsService = settingsService
  result.client = newHttpClient()
  result.favorites = @[]
  result.recents = @[]

proc setTenorAPIKey(self: Service) =
  try:
    let response = status_gif.setTenorAPIKey(TENOR_API_KEY_RESOLVED)
    if(not response.error.isNil):
      error "error setTenorAPIKey: ", errDescription = response.error.message

  except Exception as e:
    error "error: ", methodName="setTenorAPIKey", errName = e.name, errDesription = e.msg

proc getRecentGifs(self: Service) =
  try:
    let response = status_gif.getRecentGifs()

    if(not response.error.isNil):
      error "error getRecentGifs: ", errDescription = response.error.message

    self.recents = map(response.result.getElems(), settingToGifDto)

  except Exception as e:
    error "error: ", methodName="getRecentGifs", errName = e.name, errDesription = e.msg

proc getFavoriteGifs(self: Service) =
  try:
    let response = status_gif.getFavoriteGifs()

    if(not response.error.isNil):
      error "error getFavoriteGifs: ", errDescription = response.error.message

    self.favorites = map(response.result.getElems(), settingToGifDto)

  except Exception as e:
    error "error: ", methodName="getFavoriteGifs", errName = e.name, errDesription = e.msg

method init*(self: Service) =
  # set Tenor API Key
  self.setTenorAPIKey()

  # get recent and favorite gifs on the database
  self.getRecentGifs()
  self.getFavoriteGifs()

proc tenorQuery(self: Service, path: string): seq[GifDto] =
  try:
    let response = status_gif.fetchGifs(path)
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
  discard status_gif.updateRecentGifs(recent)

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
  discard status_gif.updateFavoriteGifs(favorites)
