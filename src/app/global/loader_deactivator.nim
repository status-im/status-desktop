import nimqml
import std/deques

const MAX_CHATS_IN_MEMORY = 5

type
  ChatInMemory = tuple
    sectionId: string
    chatId: string

QtObject:
  type LoaderDeactivator* = ref object of QObject
    keepInMemory: Deque[ChatInMemory]

  proc setup(self: LoaderDeactivator) =
    self.QObject.setup
    self.keepInMemory = initDeque[ChatInMemory]()

  proc delete*(self: LoaderDeactivator) =
    self.QObject.delete

  proc newLoaderDeactivator*():
    LoaderDeactivator =
    new(result, delete)
    result.setup

  proc newChatInMemory(sectionId, chatId: string): ChatInMemory =
    (sectionId, chatId)

  proc addChatInMemory*(self: LoaderDeactivator, sectionId, chatId: string): ChatInMemory =
    if self.keepInMemory.contains(newChatInMemory(sectionId, chatId)):
      return
    
    self.keepInMemory.addFirst(newChatInMemory(sectionId, chatId))

    if self.keepInMemory.len > MAX_CHATS_IN_MEMORY:
      result = self.keepInMemory.popLast()