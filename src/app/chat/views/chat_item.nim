import NimQml
import std/wrapnils
import ../../../status/chat

QtObject:
  type ChatItemView* = ref object of QObject
    chatItem*: ChatItem

  proc setup(self: ChatItemView) =
    self.QObject.setup

  proc delete*(self: ChatItemView) =
    self.QObject.delete

  proc newChatItemView*(): ChatItemView =
    new(result, delete)
    result = ChatItemView()
    result.setup

  proc setChatItem*(self: ChatItemView, chatItem: ChatItem) =
    self.chatItem = chatItem

  proc id*(self: ChatItemView): string {.slot.} = result = ?.self.chatItem.id
  QtProperty[string] id:
    read = id

  proc name*(self: ChatItemView): string {.slot.} = result = ?.self.chatItem.name
  QtProperty[string] name:
    read = name

  proc identicon*(self: ChatItemView): string {.slot.} = result = ?.self.chatItem.identicon
  QtProperty[string] identicon:
    read = identicon

  proc chatType*(self: ChatItemView): int {.slot.} =
    if self.chatItem != nil:
      result = self.chatItem.chatType.int
    else:
      result = 0
  QtProperty[int] chatType:
    read = chatType
