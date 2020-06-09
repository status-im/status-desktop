import NimQml
import std/wrapnils
import ../../../status/chat
import ../../../signals/types

QtObject:
  type ChatItemView* = ref object of QObject
    chatItem*: Chat

  proc setup(self: ChatItemView) =
    self.QObject.setup

  proc delete*(self: ChatItemView) =
    self.QObject.delete

  proc newChatItemView*(): ChatItemView =
    new(result, delete)
    result = ChatItemView()
    result.chatItem = nil
    result.setup

  proc setChatItem*(self: ChatItemView, chatItem: Chat) =
    self.chatItem = chatItem

  proc id*(self: ChatItemView): string {.slot.} = result = ?.self.chatItem.id
  
  QtProperty[string] id:
    read = id

  proc name*(self: ChatItemView): string {.slot.} = result = ?.self.chatItem.name
  
  QtProperty[string] name:
    read = name

  proc color*(self: ChatItemView): string {.slot.} = result = ?.self.chatItem.color

  QtProperty[string] color:
    read = color

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
