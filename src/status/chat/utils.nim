proc formatChatUpdate(response: JsonNode): (seq[Chat], seq[Message]) =
  var chats: seq[Chat] = @[]
  var messages: seq[Message] = @[]
  if response["result"]{"messages"} != nil:
    for jsonMsg in response["result"]["messages"]:
      messages.add(jsonMsg.toMessage())
  if response["result"]{"chats"} != nil:
    for jsonChat in response["result"]["chats"]:
      chats.add(jsonChat.toChat)
  result = (chats, messages)

# This may be moved later to some common file.
# We may create a macro for these template procedures aslo.
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