import json
import ../types/[message, chat]

proc formatChatUpdate*(response: JsonNode): (seq[Chat], seq[Message]) =
  var chats: seq[Chat] = @[]
  var messages: seq[Message] = @[]
  if response["result"]{"messages"} != nil:
    for jsonMsg in response["result"]["messages"]:
      messages.add(jsonMsg.toMessage())
  if response["result"]{"chats"} != nil:
    for jsonChat in response["result"]["chats"]:
      chats.add(jsonChat.toChat)
  result = (chats, messages)