import json
import web3/ethtypes
import types

template getProp(obj: JsonNode, prop: string, value: var typedesc[int]): bool =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = obj[prop].getInt
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[int64]): bool =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = obj[prop].getBiggestInt
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[uint]): bool =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = uint(obj[prop].getInt)
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[uint64]): bool =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = uint64(obj[prop].getBiggestInt)
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[string]): bool =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = obj[prop].getStr
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[float]): bool =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = obj[prop].getFloat
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[bool]): bool =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = obj[prop].getBool
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[JsonNode]): bool =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = obj[prop]
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[Address]): bool =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = fromHex(Address, obj[prop].getStr)
    success = true

  success

template getProp(obj: JsonNode, prop: string, value: var typedesc[MemberRole]): bool =
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = MemberRole(obj[prop].getInt)
    success = true

  success