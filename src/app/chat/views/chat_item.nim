import NimQml
import std/wrapnils
import ../../../status/chat/chat
import chat_members

QtObject:
  type ChatItemView* = ref object of QObject
    chatItem*: Chat
    chatMembers*: ChatMembersView

  proc setup(self: ChatItemView) =
    self.QObject.setup

  proc delete*(self: ChatItemView) =
    self.QObject.delete

  proc newChatItemView*(): ChatItemView =
    new(result, delete)
    result = ChatItemView()
    result.chatItem = nil
    result.chatMembers = newChatMembersView()
    result.setup

  proc setChatItem*(self: ChatItemView, chatItem: Chat) =
    self.chatItem = chatItem
    self.chatMembers.setMembers(chatItem.members)

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

  proc getMembers*(self: ChatItemView): QVariant {.slot.} =
    result = newQVariant(self.chatMembers)

  QtProperty[QVariant] members:
    read = getMembers
