import NimQml, Tables, std/wrapnils
import ../../../status/[chat/chat, status, ens, accounts]
from ../../../status/libstatus/types import Setting
import ../../../status/libstatus/settings as status_settings

import chat_members

QtObject:
  type ChatItemView* = ref object of QObject
    chatItem*: Chat
    chatMembers*: ChatMembersView
    status*: Status

  proc setup(self: ChatItemView) =
    self.QObject.setup

  proc delete*(self: ChatItemView) =
    if not self.chatMembers.isNil: self.chatMembers.delete
    self.QObject.delete

  proc newChatItemView*(status: Status): ChatItemView =
    new(result, delete)
    result = ChatItemView()
    result.chatItem = nil
    result.status = status
    result.chatMembers = newChatMembersView(status)
    result.setup

  proc setChatItem*(self: ChatItemView, chatItem: Chat) =
    self.chatItem = chatItem
    self.chatMembers.setMembers(chatItem.members)

  proc id*(self: ChatItemView): string {.slot.} = result = ?.self.chatItem.id
  
  QtProperty[string] id:
    read = id

  proc contactsUpdated*(self: ChatItemView) {.signal}

  proc userNameOrAlias(self: ChatItemView, pubKey: string): string {.slot.} =
    if self.status.chat.contacts.hasKey(pubKey):
      return ens.userNameOrAlias(self.status.chat.contacts[pubKey])
    generateAlias(pubKey)

  proc name*(self: ChatItemView): string {.slot.} = 
    if self.chatItem != nil and self.chatItem.chatType.isOneToOne:
      if self.chatItem.name == self.chatItem.id:
        result = self.userNameOrAlias(self.chatItem.id)
      else:
        if self.status.chat.contacts.hasKey(self.chatItem.id) and self.status.chat.contacts[self.chatItem.id].hasNickname():
          return self.status.chat.contacts[self.chatItem.id].localNickname
        if self.chatItem.ensName != "":
          result = "@" & userName(self.chatItem.ensName).userName(true)      
        else:
          result = self.chatItem.name
    else:
      result = ?.self.chatItem.name
    

  QtProperty[string] name:
    read = name
    notify = contactsUpdated
  
  proc ensVerified*(self: ChatItemView): bool {.slot.} = 
    if self.chatItem != nil and
      self.chatItem.chatType.isOneToOne and
      self.status.chat.contacts.hasKey(self.chatItem.id):
        return self.status.chat.contacts[self.chatItem.id].ensVerified
    result = false

  QtProperty[bool] ensVerified:
    read = ensVerified
    notify = contactsUpdated
  
  proc alias*(self: ChatItemView): string {.slot.} = 
    if self.chatItem != nil and
      self.chatItem.chatType.isOneToOne and
      self.status.chat.contacts.hasKey(self.chatItem.id):
        return self.status.chat.contacts[self.chatItem.id].alias
    result = ""

  QtProperty[string] alias:
    read = alias
    notify = contactsUpdated

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

  proc hasMentions*(self: ChatItemView): bool {.slot.} = result = ?.self.chatItem.hasMentions

  QtProperty[bool] hasMentions:
    read = hasMentions

  proc isMember*(self: ChatItemView): bool {.slot.} =
    if self.chatItem.isNil: return false
    let pubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")
    return self.chatItem.isMember(pubKey)

  proc membershipChanged*(self: ChatItemView) {.signal.}

  QtProperty[bool] isMember:
    read = isMember
    notify = membershipChanged

  proc contains*(self: ChatItemView, pubKey: string): bool {.slot.} =
    if self.chatItem.isNil: return false
    return self.chatItem.contains(pubKey)

  proc isAdmin*(self: ChatItemView, pubKey: string): bool {.slot.} =
    if self.chatItem.isNil: return false
    return self.chatItem.isAdmin(pubKey)
