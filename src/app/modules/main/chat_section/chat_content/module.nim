import NimQml, chronicles, sequtils, sugar
import io_interface
import ../io_interface as delegate_interface
import view, controller
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
  contactService: contact_service.Service, chatService: chat_service.Service,
  communityService: community_service.Service, messageService: message_service.Service, gifService: gif_service.Service,
  mailserversService: mailservers_service.Service):
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
  contactService, communityService, chatService, messageService, mailserversService)
  result.usersModule = users_module.newModule(
    result, events, sectionId, chatId, belongsToCommunity, isUsersListAvailable,
    contactService, chat_service, communityService, messageService
  )

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
  var chatImage = chatDto.icon
  var isContact = false
  var trustStatus = TrustStatus.Unknown
  if(chatDto.chatType == ChatType.OneToOne):
    let contactDto = self.controller.getContactById(self.controller.getMyChatId())
    chatName = contactDto.userNameOrAlias()
    isContact = contactDto.isContact
    trustStatus = contactDto.trustStatus
    if(contactDto.image.thumbnail.len > 0):
      chatImage = contactDto.image.thumbnail

  self.view.load(chatDto.id, chatDto.chatType.int, self.controller.belongsToCommunity(),
    self.controller.isUsersListAvailable(), chatName, chatImage,
    chatDto.color, chatDto.description, chatDto.emoji, hasNotification, notificationsCount,
    chatDto.muted, chatDto.position, isUntrustworthy = trustStatus == TrustStatus.Untrustworthy,
    isContact)

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

method currentUserWalletContainsAddress(self: Module, address: string): bool =
  if (address.len == 0):
    return false
  let accounts = self.controller.getWalletAccounts()
  for acc in accounts:
    if (acc.address == address):
      return true
  return false

proc buildPinnedMessageItem(self: Module, messageId: string, actionInitiatedBy: string, item: var pinned_msg_item.Item):
  bool =
  let (m, reactions, err) = self.controller.getMessageDetails(messageId)
  if(err.len > 0):
    return false

  let contactDetails = self.controller.getContactDetails(m.`from`)

  var transactionContract = m.transactionParameters.contract
  var transactionValue = m.transactionParameters.value
  var isCurrentUser = contactDetails.isCurrentUser
  if(m.contentType.ContentType == ContentType.Transaction):
    (transactionContract, transactionValue) = self.controller.getTransactionDetails(m)
    if m.transactionParameters.fromAddress != "":
      isCurrentUser = self.currentUserWalletContainsAddress(m.transactionParameters.fromAddress)
  item = pinned_msg_item.initItem(
    m.id,
    m.communityId,
    m.responseTo,
    m.`from`,
    contactDetails.displayName,
    contactDetails.details.localNickname,
    contactDetails.icon,
    isCurrentUser,
    contactDetails.details.added,
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
    newTransactionParametersItem(m.transactionParameters.id,
      m.transactionParameters.fromAddress,
      m.transactionParameters.address,
      transactionContract,
      transactionValue,
      m.transactionParameters.transactionHash,
      m.transactionParameters.commandState,
      m.transactionParameters.signature),
    m.mentionedUsersPks,
    contactDetails.details.trustStatus,
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
  self.controller.getMyMutualContacts().filter(x => x.id == contactId).len > 0

method muteChat*(self: Module) =
  self.controller.muteChat()

method unmuteChat*(self: Module) =
  self.controller.unmuteChat()

method unblockChat*(self: Module) =
  self.controller.unblockChat()

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
      item.senderTrustStatus = updatedContact.details.trustStatus
    if(item.messageContainsMentions):
      let (m, _, err) = self.controller.getMessageDetails(item.id)
      if(err.len == 0):
        item.messageText = self.controller.getRenderedText(m.parsedText)
        item.messageContainsMentions = m.containsContactMentions()

  if(self.controller.getMyChatId() == contactId):
    self.view.updateChatDetailsNameAndIcon(updatedContact.displayName, updatedContact.icon)
    self.view.updateTrustStatus(updatedContact.details.trustStatus == TrustStatus.Untrustworthy)

method onNotificationsUpdated*(self: Module, hasUnreadMessages: bool, notificationCount: int) =
  self.view.updateChatDetailsNotifications(hasUnreadMessages, notificationCount)

method onChatEdited*(self: Module, chatDto: ChatDto) =
  self.view.updateChatDetails(chatDto.name, chatDto.description, chatDto.emoji, chatDto.color, chatDto.chatType == ChatType.OneToOne)
  self.messagesModule.updateChatIdentifier()

method onChatRenamed*(self: Module, newName: string) =
  self.view.updateChatDetailsName(newName)
  self.messagesModule.updateChatIdentifier()

method downloadMessages*(self: Module, filePath: string) =
  let messages = self.messagesModule.getMessages()
  self.controller.downloadMessages(messages, filePath)

method onMutualContactChanged*(self: Module) =
  let contactDto = self.controller.getContactById(self.controller.getMyChatId())
  let isContact = contactDto.isContact
  self.view.onMutualContactChanged(isContact)

method contactTrustStatusChanged*(self: Module, publicKey: string, isUntrustworthy: bool) =
    self.view.updateTrustStatus(isUntrustworthy)
