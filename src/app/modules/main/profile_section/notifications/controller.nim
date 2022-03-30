import Tables, chronicles
import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/chat/service as chat_service

logScope:
  topics = "profile-section-notifications-module-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    chatService: chat_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  chatService: chat_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.chatService = chatService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(chat_service.SIGNAL_CHAT_MUTED) do(e:Args):
    let args = chat_service.ChatArgs(e)
    self.delegate.onChatMuted(args.chatId)

  self.events.on(chat_service.SIGNAL_CHAT_UNMUTED) do(e:Args):
    let args = chat_service.ChatArgs(e)
    self.delegate.onChatUnmuted(args.chatId)

  self.events.on(chat_service.SIGNAL_CHAT_LEFT) do(e: Args):
    let args = chat_service.ChatArgs(e)
    self.delegate.onChatLeft(args.chatId)

  ## We need to add leave community handler here, once we have appropriate signal in place

proc getAllChats*(self: Controller): seq[ChatDto] =
  return self.chatService.getAllChats()

proc getChatDetails*(self: Controller, chatId: string): ChatDto =
  return self.chatService.getChatById(chatId)

proc getOneToOneChatNameAndImage*(self: Controller, chatId: string):
  tuple[name: string, image: string] =
  return self.chatService.getOneToOneChatNameAndImage(chatId)

proc unmuteChat*(self: Controller, chatId: string) =
  self.chatService.unmuteChat(chatId)
