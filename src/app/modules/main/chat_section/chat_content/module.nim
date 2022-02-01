import NimQml, chronicles, sequtils, sugar
import io_interface
import ../io_interface as delegate_interface
import view, controller
import ../../../shared_models/message_model as pinned_msg_model
import ../../../shared_models/message_item as pinned_msg_item
import ../../../shared_models/message_reaction_item as pinned_msg_reaction_item
import ../../../../global/global_singleton
import ../../../../core/eventemitter

import input_area/module as input_area_module
import messages/module as messages_module
import users/module as users_module

import ../../../../../app_service/service/settings/service_interface as settings_service
import ../../../../../app_service/service/contacts/service as contact_service
import ../../../../../app_service/service/chat/service as chat_service
import ../../../../../app_service/service/community/service as community_service
import ../../../../../app_service/service/gif/service as gif_service
import ../../../../../app_service/service/message/service as message_service

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
  belongsToCommunity: bool, isUsersListAvailable: bool, settingsService: settings_service.ServiceInterface, 
  contactService: contact_service.Service, chatService: chat_service.Service, 
  communityService: community_service.Service, messageService: message_service.Service, gifService: gif_service.Service):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, sectionId, chatId, belongsToCommunity, 
  isUsersListAvailable, settingsService, contactService, chatService, communityService, messageService)
  result.moduleLoaded = false

  result.inputAreaModule = input_area_module.newModule(result, sectionId, chatId, belongsToCommunity, chatService, communityService, gifService)
  result.messagesModule = messages_module.newModule(result, events, sectionId, chatId, belongsToCommunity, 
  contactService, communityService, chatService, messageService)
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
    self.controller.isUsersListAvailable(), chatName, chatImage, isIdenticon,
    chatDto.color, chatDto.description, hasNotification, notificationsCount,
    chatDto.muted, chatDto.position)
 
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

proc buildPinnedMessageItem(self: Module, messageId: string, actionInitiatedBy: string, item: var pinned_msg_item.Item): 
  bool = 
  let (m, reactions, err) = self.controller.getMessageDetails(messageId)
  if(err.len > 0):
    return false

  let contactDetails = self.controller.getContactDetails(m.`from`)
    
  item = pinned_msg_item.initItem(
    m.id,
    m.responseTo,
    m.`from`,
    contactDetails.displayName,
    contactDetails.details.localNickname,
    contactDetails.icon, 
    contactDetails.isIdenticon,
    contactDetails.isCurrentUser,
    m.outgoingStatus,
    self.controller.getRenderedText(m.parsedText),
    m.image,
    m.containsContactMentions(),
    m.seen,
    m.timestamp,
    m.contentType.ContentType, 
    m.messageType,
    self.controller.decodeContentHash(m.sticker.hash),
    m.sticker.pack,
    m.links,
  )
  item.pinned = true
  item.pinnedBy = actionInitiatedBy

  for r in reactions:
    if(r.messageId == m.id):
      var emojiIdAsEnum: pinned_msg_reaction_item.EmojiId
      if(pinned_msg_reaction_item.toEmojiIdAsEnum(r.emojiId, emojiIdAsEnum)):
        let userWhoAddedThisReaction = self.controller.getContactById(r.`from`)
        let didIReactWithThisEmoji = userWhoAddedThisReaction.id == singletonInstance.userProfile.getPubKey()
        item.addReaction(emojiIdAsEnum, didIReactWithThisEmoji, userWhoAddedThisReaction.id, 
        userWhoAddedThisReaction.userNameOrAlias(), r.id)
      else:
        error "wrong emoji id found when loading messages", methodName="buildPinnedMessageItem"

  return true

method newPinnedMessagesLoaded*(self: Module, pinnedMessages: seq[PinnedMessageDto]) = 
  var viewItems: seq[pinned_msg_item.Item] 
  for p in pinnedMessages:
    var item: pinned_msg_item.Item
    if(not self.buildPinnedMessageItem(p.message.id, p.pinnedBy, item)):
      continue

    viewItems = item & viewItems # messages are sorted from the most recent to the least recent one

  if(viewItems.len == 0):
    return
  self.view.pinnedModel().prependItems(viewItems)

method unpinMessage*(self: Module, messageId: string) =
  self.controller.unpinMessage(messageId)

method onUnpinMessage*(self: Module, messageId: string) =
  self.view.pinnedModel().removeItem(messageId)

method onPinMessage*(self: Module, messageId: string, actionInitiatedBy: string) =
  var item: pinned_msg_item.Item
  if(not self.buildPinnedMessageItem(messageId, actionInitiatedBy, item)):
    return

  self.view.pinnedModel().appendItem(item)
  
method getMyChatId*(self: Module): string =
  self.controller.getMyChatId()

method isMyContact*(self: Module, contactId: string): bool =
  self.controller.getMyAddedContacts().filter(x => x.id == contactId).len > 0

method muteChat*(self: Module) =
  self.controller.muteChat()

method unmuteChat*(self: Module) =
  self.controller.unmuteChat()

method markAllMessagesRead*(self: Module) =
  self.controller.markAllMessagesRead()

method clearChatHistory*(self: Module) =
  self.controller.clearChatHistory()

method leaveChat*(self: Module) =
  self.controller.leaveChat()

method onChatMuted*(self: Module) =
  self.view.setMuted(true)

method onChatUnmuted*(self: Module) =
  self.view.setMuted(false)

method onReactionAdded*(self: Module, messageId: string, emojiId: int, reactionId: string) =
  var emojiIdAsEnum: EmojiId
  if(pinned_msg_reaction_item.toEmojiIdAsEnum(emojiId, emojiIdAsEnum)):
    let myPublicKey = singletonInstance.userProfile.getPubKey()
    let myName = singletonInstance.userProfile.getName()
    self.view.pinnedModel().addReaction(messageId, emojiIdAsEnum, didIReactWithThisEmoji = true, myPublicKey, myName, 
    reactionId)
  else:
    error "(pinned) wrong emoji id found on reaction added response", emojiId, methodName="onReactionAdded"

method onReactionRemoved*(self: Module, messageId: string, emojiId: int, reactionId: string) =
  var emojiIdAsEnum: EmojiId
  if(pinned_msg_reaction_item.toEmojiIdAsEnum(emojiId, emojiIdAsEnum)):
    self.view.pinnedModel().removeReaction(messageId, emojiIdAsEnum, reactionId, didIRemoveThisReaction = true)
  else:
    error "(pinned) wrong emoji id found on reaction remove response", emojiId, methodName="onReactionRemoved"

method toggleReactionFromOthers*(self: Module, messageId: string, emojiId: int, reactionId: string, 
  reactionFrom: string) =
  var emojiIdAsEnum: EmojiId
  if(pinned_msg_reaction_item.toEmojiIdAsEnum(emojiId, emojiIdAsEnum)):
    let item = self.view.pinnedModel().getItemWithMessageId(messageId)
    if(item.isNil):
      return

    if(item.shouldAddReaction(emojiIdAsEnum, reactionFrom)):
      let userWhoAddedThisReaction = self.controller.getContactById(reactionFrom)
      self.view.pinnedModel().addReaction(messageId, emojiIdAsEnum, didIReactWithThisEmoji = false, 
      userWhoAddedThisReaction.id, userWhoAddedThisReaction.userNameOrAlias(), reactionId)
    else:
      self.view.pinnedModel().removeReaction(messageId, emojiIdAsEnum, reactionId, didIRemoveThisReaction = false)
  else:
    error "wrong emoji id found on reaction added response", emojiId, methodName="toggleReactionFromOthers"

method getCurrentFleet*(self: Module): string =
  return self.controller.getCurrentFleet()

method amIChatAdmin*(self: Module): bool =
  if(not self.controller.belongsToCommunity()):
    let chatDto = self.controller.getChatDetails()
    for m in chatDto.members:
      if (m.id == singletonInstance.userProfile.getPubKey() and m.admin):
        return true
    return false
  else:
    let communityDto = self.controller.getCommunityDetails()
    return communityDto.admin

method onContactDetailsUpdated*(self: Module, contactId: string) =
  let updatedContact = self.controller.getContactDetails(contactId)
  for item in self.view.pinnedModel().modelContactUpdateIterator(contactId):
    if(item.senderId == contactId):
      item.senderDisplayName = updatedContact.displayName
      item.senderLocalName = updatedContact.details.localNickname
      item.senderIcon = updatedContact.icon
      item.isSenderIconIdenticon = updatedContact.isIdenticon
    if(item.messageContainsMentions):
      let (m, _, err) = self.controller.getMessageDetails(item.id)
      if(err.len == 0):
        item.messageText = self.controller.getRenderedText(m.parsedText)
        item.messageContainsMentions = m.containsContactMentions()

  if(self.controller.getMyChatId() == contactId):
    self.view.updateChatDetailsNameAndIcon(updatedContact.displayName, updatedContact.icon, updatedContact.isIdenticon)

method onNotificationsUpdated*(self: Module, hasUnreadMessages: bool, notificationCount: int) =
  self.view.updateChatDetailsNotifications(hasUnreadMessages, notificationCount)

method onChatEdited*(self: Module, chatDto: ChatDto) =
  self.view.updateChatDetails(chatDto.name, chatDto.description)
  self.messagesModule.updateChatIdentifier()

method onChatRenamed*(self: Module, newName: string) =
  self.view.updateChatDetailsName(newName)
