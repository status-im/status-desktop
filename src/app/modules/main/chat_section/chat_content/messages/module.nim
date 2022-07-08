import NimQml, chronicles
import io_interface
import ../io_interface as delegate_interface
import view, controller
import ../../../../shared_models/message_model
import ../../../../shared_models/message_item
import ../../../../shared_models/message_reaction_item
import ../../../../shared_models/message_transaction_parameters_item
import ../../../../../global/global_singleton
import ../../../../../core/eventemitter
import ../../../../../../app_service/service/contacts/dto/contacts
import ../../../../../../app_service/service/contacts/service as contact_service
import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/chat/service as chat_service
import ../../../../../../app_service/service/message/service as message_service
import ../../../../../../app_service/service/mailservers/service as mailservers_service

export io_interface

logScope:
  topics = "messages-module"

const CHAT_IDENTIFIER_MESSAGE_ID = "chat-identifier-message-id"
const FETCH_MORE_MESSAGES_MESSAGE_ID = "fetch-more_messages-message-id"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter, sectionId: string, chatId: string,
  belongsToCommunity: bool, contactService: contact_service.Service, communityService: community_service.Service,
  chatService: chat_service.Service, messageService: message_service.Service, mailserversService: mailservers_service.Service):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, sectionId, chatId, belongsToCommunity, contactService,
  communityService, chatService, messageService, mailserversService)
  result.moduleLoaded = false

# Forward declaration
proc createChatIdentifierItem(self: Module): Item
proc createFetchMoreMessagesItem(self: Module): Item

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.view.model().appendItem(self.createFetchMoreMessagesItem())
  self.view.model().appendItem(self.createChatIdentifierItem())

  self.moduleLoaded = true
  self.delegate.messagesDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

proc createFetchMoreMessagesItem(self: Module): Item =
  let chatDto = self.controller.getChatDetails()
  result = initItem(
    FETCH_MORE_MESSAGES_MESSAGE_ID,
    communityId = "",
    responseToMessageWithId = "",
    senderId = chatDto.id,
    senderDisplayName = "",
    senderLocalName = "",
    senderIcon = "",
    amISender = false,
    senderIsAdded = false,
    outgoingStatus = "",
    text = "",
    image = "",
    messageContainsMentions = false,
    seen = true,
    timestamp = 0,
    ContentType.FetchMoreMessagesButton,
    messageType = -1,
    sticker = "",
    stickerPack = -1,
    @[],
    newTransactionParametersItem("","","","","","",-1,""),
    @[],
    TrustStatus.Unknown
  )

proc createChatIdentifierItem(self: Module): Item =
  let chatDto = self.controller.getChatDetails()
  var chatName = chatDto.name
  var smallImage = ""
  var chatIcon = ""
  var senderIsAdded = false
  if(chatDto.chatType == ChatType.OneToOne):
    let sender = self.controller.getContactDetails(chatDto.id)
    senderIsAdded = sender.details.added
    (chatName, smallImage, chatIcon) = self.controller.getOneToOneChatNameAndImage()

  result = initItem(
    CHAT_IDENTIFIER_MESSAGE_ID,
    communityId = "",
    responseToMessageWithId = "",
    senderId = chatDto.id,
    senderDisplayName = chatName,
    senderLocalName = "",
    senderIcon = chatIcon,
    amISender = false,
    senderIsAdded,
    outgoingStatus = "",
    text = "",
    image = "",
    messageContainsMentions = false,
    seen = true,
    timestamp = 0,
    ContentType.ChatIdentifier,
    messageType = -1,
    sticker = "",
    stickerPack = -1,
    @[],
    newTransactionParametersItem("","","","","","",-1,""),
    @[],
    TrustStatus.Unknown
  )

proc checkIfMessageLoadedAndScrollToItIfItIs(self: Module): bool =
  let searchedMessageId = self.controller.getSearchedMessageId()
  if(searchedMessageId.len > 0):
    self.view.emitScrollMessagesUpSignal()
    let index = self.view.model().findIndexForMessageId(searchedMessageId)
    self.controller.increaseLoadingMessagesPerPageFactor()
    if(index != -1):
      self.controller.clearSearchedMessageId()
      self.controller.resetLoadingMessagesPerPageFactor()
      self.view.emitScrollToMessageSignal(index)
      return true
  return false

method currentUserWalletContainsAddress(self: Module, address: string): bool =
  if (address.len == 0):
    return false
  let accounts = self.controller.getWalletAccounts()
  for acc in accounts:
    if (acc.address == address):
      return true
  return false

method newMessagesLoaded*(self: Module, messages: seq[MessageDto], reactions: seq[ReactionDto],
  pinnedMessages: seq[PinnedMessageDto]) =
  var viewItems: seq[Item]

  if(messages.len > 0):
    for m in messages:
      let sender = self.controller.getContactDetails(m.`from`)

      let renderedMessageText = self.controller.getRenderedText(m.parsedText)
      var transactionContract = m.transactionParameters.contract
      var transactionValue = m.transactionParameters.value
      var isCurrentUser = sender.isCurrentUser
      if(m.contentType.ContentType == ContentType.Transaction):
        (transactionContract, transactionValue) = self.controller.getTransactionDetails(m)
        if m.transactionParameters.fromAddress != "":
          isCurrentUser = self.currentUserWalletContainsAddress(m.transactionParameters.fromAddress)
      var item = initItem(
        m.id,
        m.communityId,
        m.responseTo,
        m.`from`,
        sender.displayName,
        sender.details.localNickname,
        sender.icon,
        isCurrentUser,
        sender.details.added,
        m.outgoingStatus,
        renderedMessageText,
        m.image,
        m.containsContactMentions(),
        m.seen,
        m.whisperTimestamp,
        m.contentType.ContentType,
        m.messageType,
        sticker = self.controller.decodeContentHash(m.sticker.hash),
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
        m.mentionedUsersPks(),
        sender.details.trustStatus,
        )

      for r in reactions:
        if(r.messageId == m.id):
          var emojiIdAsEnum: EmojiId
          if(message_reaction_item.toEmojiIdAsEnum(r.emojiId, emojiIdAsEnum)):
            let userWhoAddedThisReaction = self.controller.getContactById(r.`from`)
            let didIReactWithThisEmoji = userWhoAddedThisReaction.id == singletonInstance.userProfile.getPubKey()
            item.addReaction(emojiIdAsEnum, didIReactWithThisEmoji, userWhoAddedThisReaction.id,
            userWhoAddedThisReaction.userNameOrAlias(), r.id)
          else:
            error "wrong emoji id found when loading messages", methodName="newMessagesLoaded"

      for p in pinnedMessages:
        if(p.message.id == m.id):
          item.pinned = true
          item.pinnedBy = p.pinnedBy

      if m.editedAt != 0:
        item.isEdited = true

      if(m.contentType.ContentType == ContentType.Gap):
        item.gapFrom = m.gapParameters.`from`
        item.gapTo = m.gapParameters.to

      # messages are sorted from the most recent to the least recent one
      viewItems.add(item)

    viewItems.add(self.createFetchMoreMessagesItem())
    viewItems.add(self.createChatIdentifierItem())
    self.view.model().removeItem(FETCH_MORE_MESSAGES_MESSAGE_ID)
    self.view.model().removeItem(CHAT_IDENTIFIER_MESSAGE_ID)
    # Add new loaded messages
    self.view.model().appendItems(viewItems)

  if(not self.view.getInitialMessagesLoaded()):
    self.view.initialMessagesAreLoaded()

  # check if this loading was caused by the click on a messages from the app search result
  discard self.checkIfMessageLoadedAndScrollToItIfItIs()

method messageAdded*(self: Module, message: MessageDto) =
  let sender = self.controller.getContactDetails(message.`from`)

  let renderedMessageText = self.controller.getRenderedText(message.parsedText)

  var transactionContract = message.transactionParameters.contract
  var transactionValue = message.transactionParameters.value
  var isCurrentUser = sender.isCurrentUser
  if message.contentType.ContentType == ContentType.Transaction:
    (transactionContract, transactionValue) = self.controller.getTransactionDetails(message)
    if message.transactionParameters.fromAddress != "":
      isCurrentUser = self.currentUserWalletContainsAddress(message.transactionParameters.fromAddress)
  # remove a message which has replace parameters filled
  let index = self.view.model().findIndexForMessageId(message.replace)
  if(index != -1):
    self.view.model().removeItem(message.replace)
  var item = initItem(
    message.id,
    message.communityId,
    message.responseTo,
    message.`from`,
    sender.displayName,
    sender.details.localNickname,
    sender.icon,
    isCurrentUser,
    sender.details.added,
    message.outgoingStatus,
    renderedMessageText,
    message.image,
    message.containsContactMentions(),
    message.seen,
    message.whisperTimestamp,
    message.contentType.ContentType,
    message.messageType,
    sticker = self.controller.decodeContentHash(message.sticker.hash),
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
    sender.details.trustStatus,
  )

  self.view.model().insertItemBasedOnTimestamp(item)

method onSendingMessageSuccess*(self: Module, message: MessageDto) =
  self.messageAdded(message)
  self.view.emitSendingMessageSuccessSignal()

method onSendingMessageError*(self: Module) =
  self.view.emitSendingMessageErrorSignal()

method loadMoreMessages*(self: Module) =
  self.controller.loadMoreMessages()

method toggleReaction*(self: Module, messageId: string, emojiId: int) =
  var emojiIdAsEnum: EmojiId
  if(message_reaction_item.toEmojiIdAsEnum(emojiId, emojiIdAsEnum)):
    let item = self.view.model().getItemWithMessageId(messageId)
    let myPublicKey = singletonInstance.userProfile.getPubKey()
    if(item.shouldAddReaction(emojiIdAsEnum, myPublicKey)):
      self.controller.addReaction(messageId, emojiId)
    else:
      let reactionId = item.getReactionId(emojiIdAsEnum, myPublicKey)
      self.controller.removeReaction(messageId, emojiId, reactionId)
  else:
    error "wrong emoji id found on reaction added response", emojiId, methodName="toggleReaction"

method onReactionAdded*(self: Module, messageId: string, emojiId: int, reactionId: string) =
  var emojiIdAsEnum: EmojiId
  if(message_reaction_item.toEmojiIdAsEnum(emojiId, emojiIdAsEnum)):
    let myPublicKey = singletonInstance.userProfile.getPubKey()
    let myName = singletonInstance.userProfile.getName()
    self.view.model().addReaction(messageId, emojiIdAsEnum, didIReactWithThisEmoji = true, myPublicKey, myName,
    reactionId)
  else:
    error "wrong emoji id found on reaction added response", emojiId, methodName="onReactionAdded"

method onReactionRemoved*(self: Module, messageId: string, emojiId: int, reactionId: string) =
  var emojiIdAsEnum: EmojiId
  if(message_reaction_item.toEmojiIdAsEnum(emojiId, emojiIdAsEnum)):
    self.view.model().removeReaction(messageId, emojiIdAsEnum, reactionId, didIRemoveThisReaction = true)
  else:
    error "wrong emoji id found on reaction remove response", emojiId, methodName="onReactionRemoved"

method toggleReactionFromOthers*(self: Module, messageId: string, emojiId: int, reactionId: string,
  reactionFrom: string) =
  var emojiIdAsEnum: EmojiId
  if(message_reaction_item.toEmojiIdAsEnum(emojiId, emojiIdAsEnum)):
    let item = self.view.model().getItemWithMessageId(messageId)
    if(item.isNil):
      info "message with this id is not loaded yet ", msgId=messageId, methodName="toggleReactionFromOthers"
      return
    if(item.shouldAddReaction(emojiIdAsEnum, reactionFrom)):
      let userWhoAddedThisReaction = self.controller.getContactById(reactionFrom)
      self.view.model().addReaction(messageId, emojiIdAsEnum, didIReactWithThisEmoji = false,
      userWhoAddedThisReaction.id, userWhoAddedThisReaction.userNameOrAlias(), reactionId)
    else:
      self.view.model().removeReaction(messageId, emojiIdAsEnum, reactionId, didIRemoveThisReaction = false)
  else:
    error "wrong emoji id found on reaction added response", emojiId, methodName="toggleReactionFromOthers"

method pinUnpinMessage*(self: Module, messageId: string, pin: bool) =
  self.controller.pinUnpinMessage(messageId, pin)

method onPinMessage*(self: Module, messageId: string, actionInitiatedBy: string) =
  self.view.model().pinUnpinMessage(messageId, true, actionInitiatedBy)

method onUnpinMessage*(self: Module, messageId: string) =
  self.view.model().pinUnpinMessage(messageId, false, "")

method getSectionId*(self: Module): string =
  return self.controller.getMySectionId()

method getChatId*(self: Module): string =
  return self.controller.getMyChatId()

method getChatType*(self: Module): int =
  let chatDto = self.controller.getChatDetails()
  return chatDto.chatType.int

method getChatColor*(self: Module): string =
  let chatDto = self.controller.getChatDetails()
  return chatDto.color

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

method pinMessageAllowedForMembers*(self: Module): bool =
  if(self.controller.belongsToCommunity()):
    let communityDto = self.controller.getCommunityDetails()
    return communityDto.adminSettings.pinMessageAllMembersEnabled
  return false

method getNumberOfPinnedMessages*(self: Module): int =
  return self.controller.getNumOfPinnedMessages()

method updateContactDetails*(self: Module, contactId: string) =
  let updatedContact = self.controller.getContactDetails(contactId)
  for item in self.view.model().modelContactUpdateIterator(contactId):
    if(item.senderId == contactId):
      item.senderDisplayName = updatedContact.displayName
      item.senderLocalName = updatedContact.details.localNickname
      item.senderIcon = updatedContact.icon
      item.senderIsAdded = updatedContact.details.added
      item.senderTrustStatus = updatedContact.details.trustStatus
    if(item.messageContainsMentions):
      let (m, _, err) = self.controller.getMessageDetails(item.id)
      if(err.len == 0):
        item.messageText = self.controller.getRenderedText(m.parsedText)
        item.messageContainsMentions = m.containsContactMentions()

method deleteMessage*(self: Module, messageId: string) =
  self.controller.deleteMessage(messageId)

method onMessageDeleted*(self: Module, messageId: string) =
  self.view.model().removeItem(messageId)

method editMessage*(self: Module, messageId: string, updatedMsg: string) =
  self.controller.editMessage(messageId, updatedMsg)

method onMessageEdited*(self: Module, message: MessageDto) =
  let itemBeforeChange = self.view.model().getItemWithMessageId(message.id)
  if(itemBeforeChange.isNil):
    return

  let mentionedUsersPks = itemBeforeChange.mentionedUsersPks
  let renderedMessageText = self.controller.getRenderedText(message.parsedText)

  self.view.model().updateEditedMsg(
    message.id,
    renderedMessageText,
    message.containsContactMentions(),
    message.links,
    message.mentionedUsersPks
    )

  # ask service to send SIGNAL_MENTIONED_IN_EDITED_MESSAGE signal if there is a new user's mention
  self.controller.checkEditedMessageForMentions(self.getChatId(), message, mentionedUsersPks)

  let messagesIds = self.view.model().findIdsOfTheMessagesWhichRespondedToMessageWithId(message.id)
  for msgId in messagesIds:
    # refreshing an item calling `self.view.model().refreshItemWithId(msgId)` doesn't work from some very weird reason
    # and that would be the correct way of updating item instead sending this signal. We should check this once we refactor
    # qml part.
    self.view.emitRefreshAMessageUserRespondedToSignal(msgId)

method onHistoryCleared*(self: Module) =
  self.view.model().clear()

method updateChatIdentifier*(self: Module) =
  # Delete the old ChatIdentifier message first
  self.view.model().removeItem(CHAT_IDENTIFIER_MESSAGE_ID)
  # Add new loaded messages
  self.view.model().appendItem(self.createChatIdentifierItem())

method getLinkPreviewData*(self: Module, link: string, uuid: string): string =
  return self.controller.getLinkPreviewData(link, uuid)

method onPreviewDataLoaded*(self: Module, previewData: string) =
  self.view.onPreviewDataLoaded(previewData)

method switchToMessage*(self: Module, messageId: string) =
  let index = self.view.model().findIndexForMessageId(messageId)
  if(index != -1):
    self.controller.clearSearchedMessageId()
    self.view.emitSwitchToMessageSignal(index)
  else:
    self.controller.setSearchedMessageId(messageId)

method scrollToMessage*(self: Module, messageId: string) =
  self.controller.setSearchedMessageId(messageId)
  if(not self.checkIfMessageLoadedAndScrollToItIfItIs()):
    self.loadMoreMessages()

method requestMoreMessages*(self: Module) =
  self.controller.requestMoreMessages()

method fillGaps*(self: Module, messageId: string) =
  self.controller.fillGaps(messageId)

method leaveChat*(self: Module) =
  self.controller.leaveChat()

method onChatMemberUpdated*(self: Module, publicKey: string, admin: bool, joined: bool) =
  let chatDto = self.controller.getChatDetails()
  if(chatDto.chatType != ChatType.PrivateGroupChat):
    return

  let myPublicKey = singletonInstance.userProfile.getPubKey()
  if(publicKey != myPublicKey):
    return

  self.view.model().refreshItemWithId(CHAT_IDENTIFIER_MESSAGE_ID)

method getMessages*(self: Module): seq[message_item.Item] =
  return self.view.model().items
