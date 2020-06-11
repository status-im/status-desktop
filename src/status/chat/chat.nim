import message

type ChatType* {.pure.}= enum
  Unknown = 0,
  OneToOne = 1, 
  Public = 2,
  PrivateGroupChat = 3

proc isOneToOne*(self: ChatType): bool = self == ChatType.OneToOne

type ChatMember* = object
  admin*: bool
  id*: string
  joined*: bool
  identicon*: string
  userName*: string

type Chat* = ref object
  id*: string # ID is the id of the chat, for public chats it is the name e.g. status, for one-to-one is the hex encoded public key and for group chats is a random uuid appended with the hex encoded pk of the creator of the chat
  name*: string
  color*: string
  identicon*: string
  active*: bool # indicates whether the chat has been soft deleted
  chatType*: ChatType
  timestamp*: int64 # indicates the last time this chat has received/sent a message
  lastClockValue*: int64 # indicates the last clock value to be used when sending messages
  deletedAtClockValue*: int64 # indicates the clock value at time of deletion, messages with lower clock value of this should be discarded
  unviewedMessagesCount*: int
  lastMessage*: Message
  members*: seq[ChatMember]
  # membershipUpdateEvents # ?

proc findIndexById*(self: seq[Chat], id: string): int =
  result = -1
  var idx = -1
  for item in self:
    inc idx
    if(item.id == id):
      result = idx
      break

proc isMember*(self: Chat, pubKey: string): bool =
  for member in self.members:
    if member.id == pubKey and member.joined: return true
  return false

