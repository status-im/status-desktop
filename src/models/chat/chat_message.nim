
type ChatMessage* = ref object
  userName*: string
  message*: string
  timestamp*: string
  identicon*: string
  isCurrentUser*: bool

proc delete*(self: ChatMessage) =
  discard

proc newChatMessage*(): ChatMessage =
  result = ChatMessage()
  result.userName = ""
  result.message = ""
  result.timestamp = "0"
  result.identicon = ""
  result.isCurrentUser = false
