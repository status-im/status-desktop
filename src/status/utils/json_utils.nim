import json

template getProp(obj: JsonNode, prop: string, value: var typedesc[int]): bool = 
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = obj[prop].getInt
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

template getProp(obj: JsonNode, prop: string, value: var typedesc[JsonNode]): bool = 
  var success = false
  if (obj.kind == JObject and obj.contains(prop)):
    value = obj[prop]
    success = true
  
  success