import httpclient
import json
import strformat
import os
import sequtils

from libstatus/gif import getRecentGifs, getFavoriteGifs, setFavoriteGifs, setRecentGifs


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
  GifItem* = object
    id*: string
    title*: string
    url*: string
    tinyUrl*: string
    height*: int

proc tenorToGifItem(jsonMsg: JsonNode): GifItem =
  return GifItem(
    id: jsonMsg{"id"}.getStr,
    title: jsonMsg{"title"}.getStr,
    url: jsonMsg{"media"}[0]["gif"]["url"].getStr,
    tinyUrl: jsonMsg{"media"}[0]["tinygif"]["url"].getStr,
    height: jsonMsg{"media"}[0]["gif"]["dims"][1].getInt
  )

proc settingToGifItem(jsonMsg: JsonNode): GifItem =
  return GifItem(
    id: jsonMsg{"id"}.getStr,
    title: jsonMsg{"title"}.getStr,
    url: jsonMsg{"url"}.getStr,
    tinyUrl: jsonMsg{"tinyUrl"}.getStr,
    height: jsonMsg{"height"}.getInt
  )

proc toJsonNode*(self: GifItem): JsonNode =
  result = %* {
    "id": self.id,
    "title": self.title,
    "url": self.url,
    "tinyUrl": self.tinyUrl,
    "height": self.height
  }

proc `$`*(self: GifItem): string =
  return fmt"GifItem(id:{self.id}, title:{self.title}, url:{self.url}, tinyUrl:{self.tinyUrl}, height:{self.height})"

type
  GifClient* = ref object
    client: HttpClient
    favorites: seq[GifItem]
    recents: seq[GifItem]
    favoritesLoaded: bool
    recentsLoaded: bool

proc newGifClient*(): GifClient =
  result = GifClient()
  result.client = newHttpClient()
  result.favorites = @[]
  result.recents = @[]

proc tenorQuery(self: GifClient, path: string): seq[GifItem] = 
  try:
    let content = self.client.getContent(fmt("{baseUrl}{path}{defaultParams}"))
    let doc = content.parseJson()

    var items: seq[GifItem] = @[]
    for json in doc["results"]:
      items.add(tenorToGifItem(json))

    return items
  except:
    echo getCurrentExceptionMsg()
    return @[]

proc search*(self: GifClient, query: string): seq[GifItem] =
  return self.tenorQuery(fmt("search?q={query}"))

proc getTrendings*(self: GifClient): seq[GifItem] =
  return self.tenorQuery("trending?")

proc getFavorites*(self: GifClient): seq[GifItem] =
  if not self.favoritesLoaded:
    self.favoritesLoaded = true
    self.favorites = map(getFavoriteGifs(){"items"}.getElems(), settingToGifItem)

  return self.favorites

proc getRecents*(self: GifClient): seq[GifItem] =
  if not self.recentsLoaded:
    self.recentsLoaded = true
    self.recents = map(getRecentGifs(){"items"}.getElems(), settingToGifItem)

  return self.recents

proc isFavorite*(self: GifClient, gifItem: GifItem): bool =
  for favorite in self.getFavorites():
    if favorite.id == gifItem.id:
      return true

  return false

proc toggleFavorite*(self: GifClient, gifItem: GifItem) =
  var newFavorites: seq[GifItem] = @[]
  var found = false

  for favoriteGif in self.getFavorites():
    if favoriteGif.id == gifItem.id:
      found = true
      continue

    newFavorites.add(favoriteGif)

  if not found:
    newFavorites.add(gifItem)

  self.favorites = newFavorites
  setFavoriteGifs(%*{"items": map(newFavorites, toJsonNode)})

proc addToRecents*(self: GifClient, gifItem: GifItem) =
  let recents = self.getRecents()
  var newRecents: seq[GifItem] = @[gifItem]
  var idx = 0

  while idx < MAX_RECENT - 1:
    if idx >= recents.len:
      break

    if recents[idx].id == gifItem.id:
      idx += 1
      continue

    newRecents.add(recents[idx])
    idx += 1
  
  self.recents = newRecents
  setRecentGifs(%*{"items": map(newRecents, toJsonNode)})