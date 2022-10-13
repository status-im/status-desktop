import strformat, stint
import ../../shared_models/message_item_qobject

type Item* = ref object
  id: string # ID is the id of the chat, for public chats it is the name e.g. status, for one-to-one is the hex encoded public key and for group chats is a random uuid appended with the hex encoded pk of the creator of the chat
  chatId: string
  communityId: string
  membershipStatus: int
  sectionId: string
  name: string
  author: string
  notificationType: int
  timestamp: int64
  read: bool
  dismissed: bool
  accepted: bool
  messageItem: MessageItem
  repliedMessageItem: MessageItem

proc initItem*(
  id: string,
  chatId: string,
  communityId: string,
  membershipStatus: int,
  sectionId: string,
  name: string,
  author: string,
  notificationType: int,
  timestamp: int64,
  read: bool,
  dismissed: bool,
  accepted: bool,
  messageItem: MessageItem,
  repliedMessageItem: MessageItem
): Item =
  result = Item()
  result.id = id
  result.chatId = chatId
  result.communityId = communityId
  result.membershipStatus = membershipStatus
  result.sectionId = sectionId
  result.name = name
  result.author = author
  result.notificationType = notificationType
  result.timestamp = timestamp
  result.read = read
  result.dismissed = dismissed
  result.accepted = accepted
  result.messageItem = messageItem
  result.repliedMessageItem = repliedMessageItem

proc `$`*(self: Item): string =
  result = fmt"""StickerItem(
    id: {self.id},
    name: {$self.name},
    chatId: {$self.chatId},
    communityId: {$self.communityId},
    membershipStatus: {$self.membershipStatus},
    sectionId: {$self.sectionId},
    author: {$self.author},
    notificationType: {$self.notificationType},
    timestamp: {$self.timestamp},
    read: {$self.read},
    dismissed: {$self.dismissed},
    accepted: {$self.accepted},
    # messageItem: {$self.messageItem},
    # repliedMessageItem: {$self.repliedMessageItem},
    ]"""

proc id*(self: Item): string =
  return self.id

proc name*(self: Item): string =
  return self.name

proc author*(self: Item): string =
  return self.author

proc chatId*(self: Item): string =
  return self.chatId

proc communityId*(self: Item): string =
  return self.communityId

proc membershipStatus*(self: Item): int =
  return self.membershipStatus

proc sectionId*(self: Item): string =
  return self.sectionId

proc notificationType*(self: Item): int =
  return self.notificationType

proc timestamp*(self: Item): int64 =
  return self.timestamp

proc read*(self: Item): bool =
  return self.read

proc `read=`*(self: Item, value: bool) =
  self.read = value

proc dismissed*(self: Item): bool =
  return self.dismissed

proc accepted*(self: Item): bool =
  return self.accepted

proc messageItem*(self: Item): MessageItem =
  return self.messageItem

proc repliedMessageItem*(self: Item): MessageItem =
  return self.repliedMessageItem