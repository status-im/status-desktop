import NimQml, chronicles, sequtils, sugar
import io_interface
import ../io_interface as delegate_interface
import view, controller
import ../../../shared_models/message_model as pinned_msg_model
import ../../../shared_models/message_item as pinned_msg_item
import ../../../../global/global_singleton

import input_area/module as input_area_module
import messages/module as messages_module
import users/module as users_module

import ../../../../../app_service/service/contacts/service as contact_service
import ../../../../../app_service/service/chat/service as chat_service
import ../../../../../app_service/service/community/service as community_service
import ../../../../../app_service/service/message/service as message_service

import eventemitter

export io_interface

logScope:
  topics = "chat-section-module"

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    inputAreaModule: input_area_module.AccessInterface
    messagesModule: messages_module.AccessInterface
    usersModule: users_module.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter, sectionId: string, chatId: string, 
  belongsToCommunity: bool, isUsersListAvailable: bool, contactService: contact_service.Service, 
  chatService: chat_service.Service, communityService: community_service.ServiceInterface, 
  messageService: message_service.Service): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, chatId, belongsToCommunity, isUsersListAvailable,
  contactService, chatService, communityService, messageService)
  result.moduleLoaded = false

  result.inputAreaModule = input_area_module.newModule(result, chatId, belongsToCommunity, chatService, communityService)
  result.messagesModule = messages_module.newModule(result, events, chatId, belongsToCommunity, contactService, 
  chatService, messageService)
  result.usersModule = users_module.newModule(result, events, sectionId, chatId, belongsToCommunity, isUsersListAvailable, 
  contactService, communityService, messageService)

method delete*(self: Module) =
  self.inputAreaModule.delete
  self.messagesModule.delete
  self.usersModule.delete
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()

  let chatDto = self.controller.getChatDetails()
  let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
  let notificationsCount = chatDto.unviewedMentionsCount
  var chatName = chatDto.name
  var chatImage = chatDto.identicon
  var isIdenticon = false
  if(chatDto.chatType == ChatType.OneToOne):
    (chatName, chatImage, isIdenticon) = self.controller.getOneToOneChatNameAndImage()

  self.view.load(chatDto.id, chatDto.chatType.int, self.controller.belongsToCommunity(), 
  self.controller.isUsersListAvailable(), chatName, chatImage, isIdenticon, chatDto.color, chatDto.description, 
  hasNotification, notificationsCount, chatDto.muted)
 
  self.inputAreaModule.load()
  self.messagesModule.load()
  self.usersModule.load()

proc checkIfModuleDidLoad(self: Module) =
  if self.moduleLoaded:
    return

  if(not self.inputAreaModule.isLoaded()):
    return

  if (not self.messagesModule.isLoaded()):
    return

  if (not self.usersModule.isLoaded()):
    return

  self.moduleLoaded = true
  self.delegate.chatContentDidLoad()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method inputAreaDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method messagesDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method usersDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getInputAreaModule*(self: Module): QVariant =
  return self.inputAreaModule.getModuleAsVariant()

method getMessagesModule*(self: Module): QVariant =
  return self.messagesModule.getModuleAsVariant()

method getUsersModule*(self: Module): QVariant =
  return self.usersModule.getModuleAsVariant()

proc buildPinnedMessageItem(self: Module, messageId: string, item: var pinned_msg_item.Item): bool = 
  let (m, reactions, err) = self.controller.getMessageDetails(messageId)
  if(err.len > 0):
    return false

  let contactDetails = self.controller.getContactDetails(m.`from`)
    
  var item = initItem(
    m.id,
    m.responseTo,
    m.`from`,
    contactDetails.displayName,
    contactDetails.localNickname,
    contactDetails.icon, 
    contactDetails.isIconIdenticon,
    contactDetails.isCurrentUser,
    m.outgoingStatus,
    m.text,
    m.image,
    m.seen,
    m.timestamp,
    m.contentType.ContentType, 
    m.messageType
  )
  item.pinned = true

  for r in reactions:
    if(r.messageId == m.id):
      # m.`from` should be replaced by appropriate ens/alias when we have that part refactored
      item.addReaction(r.emojiId, m.`from`, r.id)

  return true

method newPinnedMessagesLoaded*(self: Module, pinnedMessages: seq[PinnedMessageDto]) = 
  var viewItems: seq[Item] 
  for p in pinnedMessages:
    var item: pinned_msg_item.Item
    if(not self.buildPinnedMessageItem(p.message.id, item)):
      continue

    viewItems = item & viewItems # messages are sorted from the most recent to the least recent one

  self.view.pinnedModel().prependItems(viewItems)

method unpinMessage*(self: Module, messageId: string) =
  self.controller.unpinMessage(messageId)

method onUnpinMessage*(self: Module, messageId: string) =
  self.view.pinnedModel().removeItem(messageId)

method onPinMessage*(self: Module, messageId: string) =
  var item: pinned_msg_item.Item
  if(not self.buildPinnedMessageItem(messageId, item)):
    return

  self.view.pinnedModel().appendItem(item)
  
method getMyChatId*(self: Module): string =
  self.controller.getMyChatId()

method isMyContact*(self: Module, contactId: string): bool =
  self.controller.getMyAddedContacts().filter(x => x.id == contactId).len > 0

method unmuteChat*(self: Module) =
  self.controller.unmuteChat()

method onChatMuted*(self: Module) =
  self.view.setMuted(true)

method onChatUnmuted*(self: Module) =
  self.view.setMuted(false)