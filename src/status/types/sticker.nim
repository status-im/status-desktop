{.used.}

import json, options, typetraits
import web3/ethtypes, json_serialization, stint

type Sticker* = object
  hash*: string
  packId*: int

type StickerPack* = object
  author*: string
  id*: int
  name*: string
  price*: Stuint[256]
  preview*: string
  stickers*: seq[Sticker]
  thumbnail*: string

proc `%`*(stuint256: Stuint[256]): JsonNode =
  newJString($stuint256)

proc readValue*(reader: var JsonReader, value: var Stuint[256])
               {.raises: [IOError, SerializationError, Defect].} =
  try:
    let strVal = reader.readValue(string)
    value = strVal.parse(Stuint[256])
  except:
    try:
      let intVal = reader.readValue(int)
      value = intVal.stuint(256)
    except:
      raise newException(SerializationError, "Expected string or int representation of Stuint[256]")