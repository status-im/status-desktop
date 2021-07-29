import httpclient
import json
import strformat
import os

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
    id*: int
    title*: string
    url*: string
    height*: int

proc toGifItem(jsonMsg: JsonNode): GifItem =
  return GifItem(
    id: jsonMsg{"id"}.getInt,
    title: jsonMsg{"title"}.getStr,
    url: jsonMsg{"media"}[0]["gif"]["url"].getStr,
    height: jsonMsg{"media"}[0]["gif"]["dims"][1].getInt
  )

proc `$`*(self: GifItem): string =
  return fmt"GifItem(id:{self.id}, title:{self.title}, url:{self.url})"

type
  GifClient* = ref object
    client: HttpClient

proc newGifClient*(): GifClient =
  result = GifClient()
  result.client = newHttpClient()

proc tenorQuery(self: GifClient, path: string): seq[GifItem] = 
  try:
    let content = self.client.getContent(fmt("{baseUrl}{path}{defaultParams}"))
    let doc = content.parseJson()

    var items: seq[GifItem] = @[]
    for json in doc["results"]:
      items.add(toGifItem(json))

    return items
  except:
    echo getCurrentExceptionMsg()
    return @[]

proc search*(self: GifClient, query: string): seq[GifItem] =
  return self.tenorQuery(fmt("search?q={query}"))

proc getTrendings*(self: GifClient): seq[GifItem] =
  return self.tenorQuery("trending?")