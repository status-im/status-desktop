import eventemitter, sets
import ../status/utils
import ../status/chat as status_chat

type
  ChatModel* = ref object
    events*: EventEmitter
    channels*: HashSet[string]

proc newChatModel*(events: EventEmitter): ChatModel =
  result = ChatModel()
  result.channels = initHashSet[string]()
  result.events = events

proc delete*(self: ChatModel) =
  discard

proc hasChannel*(self: ChatModel, chatId: string): bool =
  result = self.channels.contains(chatId)

proc join*(self: ChatModel, chatId: string) =
  if self.hasChannel(chatId): return

  self.channels.incl chatId

  # TODO: save chat list in the db

  let oneToOne = isOneToOneChat(chatId)
  
  status_chat.loadFilters(chatId, oneToOne)
  status_chat.saveChat(chatId, oneToOne)
  status_chat.chatMessages(chatId)
  