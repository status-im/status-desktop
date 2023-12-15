import json
import core, ../app_service/common/utils
import response_type

export response_type

proc fetchMessages*(chatId: string, cursorVal: string, limit: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId, cursorVal, limit]
  result = callPrivateRPC("chatMessages".prefix, payload)

proc fetchPinnedMessages*(chatId: string, cursorVal: string, limit: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId, cursorVal, limit]
  result = callPrivateRPC("chatPinnedMessages".prefix, payload)

proc fetchReactions*(chatId: string, cursorVal: string, limit: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId, cursorVal, limit]
  result = callPrivateRPC("emojiReactionsByChatID".prefix, payload)

proc addReaction*(chatId: string, messageId: string, emojiId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId, messageId, emojiId]
  result = callPrivateRPC("sendEmojiReaction".prefix, payload)

proc removeReaction*(reactionId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [reactionId]
  result = callPrivateRPC("sendEmojiReactionRetraction".prefix, payload)

proc pinUnpinMessage*(chatId: string, messageId: string, pin: bool): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[{
    "message_id": messageId,
    "pinned": pin,
    "chat_id": chatId
  }]
  result = callPrivateRPC("sendPinMessage".prefix, payload)

proc markMessageAsUnread*(chatId: string, messageId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[chatId, messageId]
  result = callPrivateRPC("markMessageAsUnread".prefix, payload)

proc getMessageByMessageId*(messageId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [messageId]
  result = callPrivateRPC("messageByMessageID".prefix, payload)

proc fetchReactionsForMessageWithId*(chatId: string, messageId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId, messageId]
  result = callPrivateRPC("emojiReactionsByChatIDMessageID".prefix, payload)

proc fetchAllMessagesFromChatWhichMatchTerm*(chatId: string, searchTerm: string, caseSensitive: bool):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId, searchTerm, caseSensitive]
  result = callPrivateRPC("allMessagesFromChatWhichMatchTerm".prefix, payload)

proc fetchAllMessagesFromChatsAndCommunitiesWhichMatchTerm*(communityIds: seq[string], chatIds: seq[string],
  searchTerm: string, caseSensitive: bool): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityIds, chatIds, searchTerm, caseSensitive]
  result = callPrivateRPC("allMessagesFromChatsAndCommunitiesWhichMatchTerm".prefix, payload)

proc markAllMessagesFromChatWithIdAsRead*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId]
  result = callPrivateRPC("markAllRead".prefix, payload)

proc markCertainMessagesFromChatWithIdAsRead*(chatId: string, messageIds: seq[string]):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId, messageIds]
  result = callPrivateRPC("markMessagesRead".prefix, payload)

proc deleteMessageAndSend*(messageID: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("deleteMessageAndSend".prefix, %* [messageID])

proc editMessage*(messageId: string, contentType: int, msg: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("editMessage".prefix, %* [{"id": messageId, "text": msg, "content-type": contentType}])

proc resendChatMessage*(messageId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("reSendChatMessage".prefix, %* [messageId])

proc firstUnseenMessageID*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId]
  result = callPrivateRPC("firstUnseenMessageID".prefix, payload)

proc getTextUrls*(text: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[text]
  result = callPrivateRPC("getTextURLs".prefix, payload)

proc getTextURLsToUnfurl*(text: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[text]
  result = callPrivateRPC("getTextURLsToUnfurl".prefix, payload)

proc unfurlUrls*(urls: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[urls]
  result = callPrivateRPC("unfurlURLs".prefix, payload)
