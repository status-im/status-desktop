import json
import types

proc fromEvent*(event: JsonNode): Signal = 
  var signal:ChatSignal = ChatSignal()
  signal.messages = @[]
  for jsonMsg in event["event"]["messages"]:
    let msg = Message(
      alias: jsonMsg["alias"].getStr,
      chatId: jsonMsg["chatId"].getStr,
      clock: $jsonMsg["clock"].getInt,
      contentType: jsonMsg["contentType"].getInt,
      ensName: jsonMsg["ensName"].getStr,
      fromAuthor: jsonMsg["from"].getStr,
      id: jsonMsg["identicon"].getStr,
      identicon: jsonMsg["identicon"].getStr,
      lineCount: jsonMsg["lineCount"].getInt,
      localChatId: jsonMsg["localChatId"].getStr,
      messageType: jsonMsg["messageType"].getStr,
      replace: jsonMsg["replace"].getStr,
      responseTo: jsonMsg["responseTo"].getStr,
      rtl: jsonMsg["rtl"].getBool,
      seen: jsonMsg["seen"].getBool,
      text: jsonMsg["text"].getStr,
      timestamp: $jsonMsg["timestamp"].getInt,
      whisperTimestamp: $jsonMsg["whisperTimestamp"].getInt,
      isCurrentUser: false
    )

    signal.messages.add(msg)

  result = signal