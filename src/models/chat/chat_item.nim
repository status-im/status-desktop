import ../../app/signals/types

type ChatItem* = ref object
  name*: string
  lastMessage*: string
  timestamp*: int64
  unviewedMessagesCount*: int

proc newChatItem*(): ChatItem =
  new(result)
  result.name = ""
  result.lastMessage = ""
  result.timestamp = 0
  result.unviewedMessagesCount = 0

proc findByName*(self: seq[ChatItem], name: string): int =
  result = -1
  for item in self:
    inc result
    if(item.name == name): break

proc toChatItem*(chat: Chat): ChatItem =
    result = ChatItem(
      name: chat.name,
      lastMessage: chat.lastMessage.text,
      timestamp: chat.timestamp,
      unviewedMessagesCount: chat.unviewedMessagesCount
    )
