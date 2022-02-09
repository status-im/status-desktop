import NimQml, chronicles
import io_interface
import ../io_interface as delegate_interface
import view, controller, model, item

import ../../../../core/eventemitter
import ../../../../../app_service/service/chat/service as chat_service

export io_interface

logScope:
  topics = "profile-section-notifications-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  chatService: chat_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, chatService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc initModel(self: Module) =
  let chats = self.controller.getAllChats()
  for c in chats:
    if(not c.muted):
      continue

    if(c.chatType == ChatType.OneToOne):
      let (chatName, chatImage, isIdenticon) = self.controller.getOneToOneChatNameAndImage(c.id)
      let item = initItem(c.id, chatName, chatImage, isIdenticon, c.color)
      self.view.mutedContactsModel().addItem(item)
    else:
      let item = initItem(c.id, c.name, c.identicon, false, c.color)
      self.view.mutedChatsModel().addItem(item)

method viewDidLoad*(self: Module) =
  self.initModel()
  self.moduleLoaded = true
  self.delegate.notificationsModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method unmuteChat*(self: Module, chatId: string) =
  self.controller.unmuteChat(chatId)

method onChatMuted*(self: Module, chatId: string) =
  let chat = self.controller.getChatDetails(chatId)
  if(chat.chatType == ChatType.OneToOne):
    let (chatName, chatImage, isIdenticon) = self.controller.getOneToOneChatNameAndImage(chat.id)
    let item = initItem(chat.id, chatName, chatImage, isIdenticon, chat.color)
    self.view.mutedContactsModel().addItem(item)
  else:
    let item = initItem(chat.id, chat.name, chat.identicon, false, chat.color)
    self.view.mutedChatsModel().addItem(item)

method onChatUnmuted*(self: Module, chatId: string) =
  self.view.mutedContactsModel().removeItemById(chatId)
  self.view.mutedChatsModel().removeItemById(chatId)

method onChatLeft*(self: Module, chatId: string) =
  self.view.mutedContactsModel().removeItemById(chatId)
  self.view.mutedChatsModel().removeItemById(chatId)
