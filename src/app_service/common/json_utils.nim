import json
import web3/eth_api_types
import types

template getProp(obj: JsonNode, prop: string, value: var typedesc[int]): bool {.redefine.} =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = obj[prop].getInt
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[int64]): bool {.redefine.} =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = obj[prop].getBiggestInt
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[uint]): bool {.redefine.} =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = uint(obj[prop].getInt)
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[uint64]): bool {.redefine.} =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = uint64(obj[prop].getBiggestInt)
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[string]): bool {.redefine.} =
  var success = false
  if (obj.kind == JObject and obj.contains(prop) and obj[prop].kind == JString):
    value = obj[prop].getStr
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[float]): bool {.redefine.} =
  var success = false
  if (obj.kind == JObject and obj.contains(prop) and obj[prop].kind == JFloat):
    value = obj[prop].getFloat
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[bool]): bool {.redefine.} =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = obj[prop].getBool
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[JsonNode]): bool {.redefine.}  =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = obj[prop]
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[Address]): bool  {.redefine.} =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = fromHex(Address, obj[prop].getStr)
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[MemberRole]): bool  {.redefine.} =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = MemberRole(obj[prop].getInt)
    success = true

  success