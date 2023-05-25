import NimQml, chronicles, sequtils, sugar
import io_interface
import ../io_interface as delegate_interface
import view, controller

import ../item as chat_item
import ../../../shared_models/message_model as pinned_msg_model
import ../../../shared_models/message_item as pinned_msg_item
import ../../../shared_models/message_transaction_parameters_item
import ../../../shared_models/message_reaction_item as pinned_msg_reaction_item
import ../../../../global/global_singleton
import ../../../../core/eventemitter

import input_area/module as input_area_module
import messages/module as messages_module
import users/module as users_module

import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/node_configuration/service as node_configuration_service
import ../../../../../app_service/service/contacts/service as contact_service
import ../../../../../app_service/service/chat/service as chat_service
import ../../../../../app_service/service/community/service as community_service
import ../../../../../app_service/service/gif/service as gif_service
import ../../../../../app_service/service/message/service as message_service
import ../../../../../app_service/service/mailservers/service as mailservers_service

export io_interface

logScope:
  topics = "chat-section-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    inputAreaModule: input_area_module.AccessInterface
    messagesModule: messages_module.AccessInterface
    usersModule: users_module.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter, sectionId: string, chatId: string,
  belongsToCommunity: bool, isUsersListAvailable: bool, settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service, contactService: contact_service.Service, chatService: chat_service.Service,
  communityService: community_service.Service, messageService: message_service.Service, gifService: gif_service.Service,
  mailserversService: mailservers_service.Service, communityUsersModule: users_module.AccessInterface):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, sectionId, chatId, belongsToCommunity,
    isUsersListAvailable, settingsService, nodeConfigurationService, contactService, chatService, communityService, messageService)
  result.moduleLoaded = false

  result.inputAreaModule = input_area_module.newModule(result, events, sectionId, chatId, belongsToCommunity, chatService, communityService, gifService)
  result.messagesModule = messages_module.newModule(result, events, sectionId, chatId, belongsToCommunity,
    contactService, communityService, chatService, messageService, mailserversService)
  result.usersModule = 
    if communityUsersModule == nil: 
      users_module.newModule( events, sectionId, chatId, belongsToCommunity, 
      isUsersListAvailable, contactService, chat_service, communityService, messageService)
    else: communityUsersModule

method delete*(self: Module) =
  self.controller.delete
  self.view.delete
  self.viewVariant.delete
  self.inputAreaModule.delete
  self.messagesModule.delete
  if self.usersModule != nil:
    self.usersModule.delete

method load*(self: Module, chatItem: chat_item.Item) =
  self.controller.init()

  var chatName = chatItem.name
  var chatImage = chatItem.icon
  var isContact = false
  var trustStatus = TrustStatus.Unknown
  if(chatItem.`type` == ChatType.OneToOne.int):
    let contactDto = self.controller.getContactById(self.controller.getMyChatId())
    chatName = contactDto.userDefaultDisplayName()
    isContact = contactDto.isContact
    trustStatus = contactDto.trustStatus
    if(contactDto.image.thumbnail.len > 0):
      chatImage = contactDto.image.thumbnail

  self.usersModule.load()

  self.view.load(chatItem.id, chatItem.`type`, self.controller.belongsToCommunity(),
    self.controller.isUsersListAvailable(), chatName, chatImage,
    chatItem.color, chatItem.description, chatItem.emoji, chatItem.hasUnreadMessages, chatItem.notificationsCount,
    chatItem.muted, chatItem.position, isUntrustworthy = trustStatus == TrustStatus.Untrustworthy,
    isContact)

  self.inputAreaModule.load()
  self.messagesModule.load()

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

proc currentUserWalletContainsAddress(self: Module, address: string): bool =
  if (address.len == 0):
    return false
  let accounts = self.controller.getWalletAccounts()
  for acc in accounts:
    if (acc.address == address):
      return true
  return false

proc buildPinnedMessageItem(self: Module, message: MessageDto, actionInitiatedBy: string,
    item: var pinned_msg_item.Item):bool =

  let contactDetails = self.controller.getContactDetails(message.`from`)
  let chatDetails = self.controller.getChatDetails()
  let communityChats = self.controller.getCommunityById(chatDetails.communityId).chats
  var quotedMessageAuthorDetails = ContactDetails()
  if message.quotedMessage.`from` != "":
    if(message.`from` == message.quotedMessage.`from`):
      quotedMessageAuthorDetails = contactDetails
    else:
      quotedMessageAuthorDetails = self.controller.getContactDetails(message.quotedMessage.`from`)

  var transactionContract = message.transactionParameters.contract
  var transactionValue = message.transactionParameters.value
  var isCurrentUser = contactDetails.isCurrentUser
  if(message.contentType == ContentType.Transaction):
    (transactionContract, transactionValue) = self.controller.getTransactionDetails(message)
    if message.transactionParameters.fromAddress != "":
      isCurrentUser = self.currentUserWalletContainsAddress(message.transactionParameters.fromAddress)
  item = pinned_msg_item.initItem(
    message.id,
    message.communityId,
    message.responseTo,
    message.`from`,
    contactDetails.defaultDisplayName,
    contactDetails.optionalName,
    contactDetails.icon,
    contactDetails.colorHash,
    isCurrentUser,
    contactDetails.dto.added,
    message.outgoingStatus,
    self.controller.getRenderedText(message.parsedText, communityChats),
    self.controller.replacePubKeysWithDisplayNames(message.text),
    message.parsedText,
    message.image,
    message.containsContactMentions(),
    message.seen,
    timestamp = message.timestamp,
    clock = message.clock,
    message.contentType,
    message.messageType,
    message.contactRequestState,
    message.sticker.url,
    message.sticker.pack,
    message.links,
    newTransactionParametersItem(message.transactionParameters.id,
      message.transactionParameters.fromAddress,
      message.transactionParameters.address,
      transactionContract,
      transactionValue,
      message.transactionParameters.transactionHash,
      message.transactionParameters.commandState,
      message.transactionParameters.signature),
    message.mentionedUsersPks,
    contactDetails.dto.trustStatus,
    contactDetails.dto.ensVerified,
    message.discordMessage,
    resendError = "",
    message.mentioned,
    message.quotedMessage.`from`,
    message.quotedMessage.text,
    self.controller.getRenderedText(message.quotedMessage.parsedText, communityChats),
    message.quotedMessage.contentType,
    message.quotedMessage.deleted,
    message.quotedMessage.discordMessage,
    quotedMessageAuthorDetails,
    message.albumId,
    if (len(message.albumId) == 0): @[] else: @[message.image],
    if (len(message.albumId) == 0): @[] else: @[message.id],
    message.albumImagesCount,
  )
  item.pinned = true
  item.pinnedBy = actionInitiatedBy

  return true

method newPinnedMessagesLoaded*(self: Module, pinnedMessages: seq[PinnedMessageDto]) =
  var viewItems: seq[pinned_msg_item.Item]
  for p in pinnedMessages:
    var item: pinned_msg_item.Item
    if(not self.buildPinnedMessageItem(p.message, p.pinnedBy, item)):
      continue

    viewItems = item & viewItems # messages are sorted from the most recent to the least recent one

  if(viewItems.len == 0):
    return
  self.view.pinnedModel().insertItemsBasedOnClock(viewItems)

method unpinMessage*(self: Module, messageId: string) =
  self.controller.unpinMessage(messageId)

method onUnpinMessage*(self: Module, messageId: string) =
  self.view.pinnedModel().removeItem(messageId)

method onPinMessage*(self: Module, messageId: string, actionInitiatedBy: string) =
  var item: pinned_msg_item.Item
  let (message, err) = self.controller.getMessageById(messageId)
  if(err.len > 0 or not self.buildPinnedMessageItem(message, actionInitiatedBy, item)):
    return

  self.view.pinnedModel().insertItemBasedOnClock(item)

method getMyChatId*(self: Module): string =
  self.controller.getMyChatId()

method isMyContact*(self: Module, contactId: string): bool =
  self.controller.getMyMutualContacts().filter(x => x.id == contactId).len > 0

method muteChat*(self: Module, interval: int) =
  self.controller.muteChat(interval)

method unmuteChat*(self: Module) =
  self.controller.unmuteChat()

method unblockChat*(self: Module) =
  self.controller.unblockChat()

method markAllMessagesRead*(self: Module) =
  self.controller.markAllMessagesRead()

method markMessageRead*(self: Module, msgID: string) =
  self.controller.markMessageRead(msgID)

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
      userWhoAddedThisReaction.id, userWhoAddedThisReaction.userDefaultDisplayName(), reactionId)
    else:
      self.view.pinnedModel().removeReaction(messageId, emojiIdAsEnum, reactionId, didIRemoveThisReaction = false)
  else:
    error "wrong emoji id found on reaction added response", emojiId, methodName="toggleReactionFromOthers"

method getCurrentFleet*(self: Module): string =
  return self.controller.getCurrentFleet()

method amIChatAdmin*(self: Module): bool =
  if(not self.controller.belongsToCommunity()):
    let chatDto = self.controller.getChatDetails()
    for member in chatDto.members:
      if (member.id == singletonInstance.userProfile.getPubKey() and member.admin):
        return true
    return false
  else:
    let communityDto = self.controller.getCommunityDetails()
    return communityDto.admin

method onContactDetailsUpdated*(self: Module, contactId: string) =
  let updatedContact = self.controller.getContactDetails(contactId)
  for item in self.view.pinnedModel().modelContactUpdateIterator(contactId):
    if item.senderId == contactId:
      item.senderDisplayName = updatedContact.defaultDisplayName
      item.senderOptionalName = updatedContact.optionalName
      item.senderEnsVerified = updatedContact.dto.ensVerified
      item.senderIcon = updatedContact.icon
      item.senderTrustStatus = updatedContact.dto.trustStatus

    if item.quotedMessageAuthorDetails.dto.id == contactId:
      item.quotedMessageAuthorDetails = updatedContact
      item.quotedMessageAuthorDisplayName = updatedContact.defaultDisplayName
      item.quotedMessageAuthorAvatar = updatedContact.icon

    if item.messageContainsMentions and item.mentionedUsersPks.anyIt(it == contactId):
      let chatDetails = self.controller.getChatDetails()
      let communityChats = self.controller.getCommunityById(chatDetails.communityId).chats
      item.messageText = self.controller.getRenderedText(item.parsedText, communityChats)

  if(self.controller.getMyChatId() == contactId):
    self.view.updateChatDetailsNameAndIcon(updatedContact.defaultDisplayName, updatedContact.icon)
    self.view.updateTrustStatus(updatedContact.dto.trustStatus == TrustStatus.Untrustworthy)

method onNotificationsUpdated*(self: Module, hasUnreadMessages: bool, notificationCount: int) =
  self.view.updateChatDetailsNotifications(hasUnreadMessages, notificationCount)

method onChatEdited*(self: Module, chatDto: ChatDto) =
  self.view.updateChatDetails(chatDto)
  self.messagesModule.updateChatFetchMoreMessages()
  self.messagesModule.updateChatIdentifier()

method onChatRenamed*(self: Module, newName: string) =
  self.view.updateChatDetailsName(newName)
  self.messagesModule.updateChatIdentifier()

method onGroupChatDetailsUpdated*(self: Module, newName: string, newColor: string, newImage: string) =
  self.view.updateChatDetailsNameColorIcon(newName, newColor, newImage)
  self.messagesModule.updateChatIdentifier()

method downloadMessages*(self: Module, filePath: string) =
  let messages = self.messagesModule.getMessages()
  self.controller.downloadMessages(messages, filePath)

method onMutualContactChanged*(self: Module) =
  let contactDto = self.controller.getContactById(self.controller.getMyChatId())
  let isContact = contactDto.isContact
  self.view.onMutualContactChanged(isContact)

method onMadeActive*(self: Module) =
  # The new messages marker is reset each time the chat is made active,
  # as messages may arrive out of order and relying on the previous
  # new messages marker could yield incorrect results.
  if not self.messagesModule.isFirstUnseenMessageInitialized() or
     self.controller.getChatDetails().unviewedMessagesCount > 0:
    self.messagesModule.resetAndScrollToNewMessagesMarker()
  self.messagesModule.reevaluateViewLoadingState()
  self.view.setActive()

method onMadeInactive*(self: Module) =
  if self.controller.getChatDetails().unviewedMessagesCount == 0:
    self.messagesModule.removeNewMessagesMarker()
  self.view.setInactive()
