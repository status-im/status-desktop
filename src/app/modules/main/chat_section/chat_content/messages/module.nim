import NimQml, chronicles, sequtils
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
const CHAT_IDENTIFIER_CLOCK = -2
const FETCH_MORE_MESSAGES_MESSAGE_ID = "fetch-more_messages-message-id"
const FETCH_MORE_MESSAGES_CLOCK = -1

type
  FirstUnseenMessageState = tuple
    initialized: bool
    fetching: bool
    scrollToWhenFetched: bool

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool
    initialMessagesLoaded: bool
    firstUnseenMessageState: FirstUnseenMessageState

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
  result.initialMessagesLoaded = false
  result.firstUnseenMessageState = (false, false, false)

# Forward declaration
proc createChatIdentifierItem(self: Module): Item
proc createFetchMoreMessagesItem(self: Module): Item
proc setChatDetails(self: Module, chatDetails: ChatDto)
proc updateItemsByAlbum(self: Module, items: var seq[Item], message: MessageDto): bool

method delete*(self: Module) =
  self.controller.delete
  self.view.delete
  self.viewVariant.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  let chatDto = self.controller.getChatDetails()
  if chatDto.hasMoreMessagesToRequest():
    self.view.model().insertItemBasedOnClock(self.createFetchMoreMessagesItem())

  self.updateChatIdentifier()
  self.view.setAmIChatAdmin(self.amIChatAdmin())
  self.view.setIsPinMessageAllowedForMembers(self.pinMessageAllowedForMembers())
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
    senderOptionalName = "",
    senderIcon = "",
    senderColorHash = "",
    amISender = false,
    senderIsAdded = false,
    outgoingStatus = "",
    text = "",
    unparsedText = "",
    parsedText = @[],
    image = "",
    messageContainsMentions = false,
    seen = true,
    timestamp = 0,
    clock = FETCH_MORE_MESSAGES_CLOCK,
    ContentType.FetchMoreMessagesButton,
    messageType = -1,
    contactRequestState = 0,
    sticker = "",
    stickerPack = -1,
    links = @[],
    transactionParameters = newTransactionParametersItem("","","","","","",-1,""),
    mentionedUsersPks = @[],
    senderTrustStatus = TrustStatus.Unknown,
    senderEnsVerified = false,
    DiscordMessage(),
    resendError = "",
    mentioned = false,
    quotedMessageFrom = "",
    quotedMessageText = "",
    quotedMessageParsedText = "",
    quotedMessageContentType = ContentType.Unknown,
    quotedMessageDeleted = false,
    quotedMessageDiscordMessage = DiscordMessage(),
    quotedMessageAuthorDetails = ContactDetails(),
    albumId = "",
    albumMessageImages = @[],
    albumMessageIds = @[],
    albumImagesCount = 0,
  )

proc createChatIdentifierItem(self: Module): Item =
  let chatDto = self.controller.getChatDetails()
  var chatName = chatDto.name
  var smallImage = ""
  var chatIcon = ""
  var senderColorHash = ""
  var senderIsAdded = false
  if(chatDto.chatType == ChatType.OneToOne):
    let sender = self.controller.getContactDetails(chatDto.id)
    senderIsAdded = sender.dto.added
    (chatName, smallImage, chatIcon) = self.controller.getOneToOneChatNameAndImage()
    senderColorHash = sender.colorHash

  result = initItem(
    CHAT_IDENTIFIER_MESSAGE_ID,
    communityId = "",
    responseToMessageWithId = "",
    senderId = chatDto.id,
    senderDisplayName = chatName,
    senderOptionalName = "",
    senderIcon = chatIcon,
    senderColorHash = senderColorHash,
    amISender = false,
    senderIsAdded,
    outgoingStatus = "",
    text = "",
    unparsedText = "",
    parsedText = @[],
    image = "",
    messageContainsMentions = false,
    seen = true,
    timestamp = 0,
    clock = CHAT_IDENTIFIER_CLOCK,
    ContentType.ChatIdentifier,
    messageType = -1,
    contactRequestState = 0,
    sticker = "",
    stickerPack = -1,
    links = @[],
    transactionParameters = newTransactionParametersItem("","","","","","",-1,""),
    mentionedUsersPks = @[],
    senderTrustStatus = TrustStatus.Unknown,
    senderEnsVerified = false,
    DiscordMessage(),
    resendError = "",
    mentioned = false,
    quotedMessageFrom = "",
    quotedMessageText = "",
    quotedMessageParsedText = "",
    quotedMessageContentType = ContentType.Unknown,
    quotedMessageDeleted = false,
    quotedMessageDiscordMessage = DiscordMessage(),
    quotedMessageAuthorDetails = ContactDetails(),
    albumId = "",
    albumMessageImages = @[],
    albumMessageIds = @[],
    albumImagesCount = 0,
  )

proc checkIfMessageLoadedAndScrollToItIfItIs(self: Module) =
  let searchedMessageId = self.controller.getSearchedMessageId()
  if(searchedMessageId.len > 0):
    let index = self.view.model().findIndexForMessageId(searchedMessageId)
    if(index != -1):
      self.controller.clearSearchedMessageId()
      self.controller.resetLoadingMessagesPerPageFactor()
      self.view.emitScrollToMessageSignal(index)
      self.view.setMessageSearchOngoing(false)
      self.reevaluateViewLoadingState()
    else:
      self.controller.increaseLoadingMessagesPerPageFactor()
      self.loadMoreMessages()

proc currentUserWalletContainsAddress(self: Module, address: string): bool =
  if (address.len == 0):
    return false
  let accounts = self.controller.getWalletAccounts()
  for acc in accounts:
    if (acc.address == address):
      return true
  return false

method reevaluateViewLoadingState*(self: Module) =
  self.view.setLoading(not self.initialMessagesLoaded or 
                       not self.firstUnseenMessageState.initialized or
                       self.firstUnseenMessageState.fetching or
                       self.view.getMessageSearchOngoing())

method newMessagesLoaded*(self: Module, messages: seq[MessageDto], reactions: seq[ReactionDto]) =
  var viewItems: seq[Item]

  if(messages.len > 0):
    for message in messages:
      # https://github.com/status-im/status-desktop/issues/7632 will introduce deleteFroMe feature.
      # Now we just skip deleted messages
      if message.deleted or message.deletedForMe:
        continue

      let chatDetails = self.controller.getChatDetails()

      let sender = self.controller.getContactDetails(message.`from`)
      var quotedMessageAuthorDetails = ContactDetails()
      if message.quotedMessage.`from` != "":
        if(message.`from` == message.quotedMessage.`from`):
          quotedMessageAuthorDetails = sender
        else:
          quotedMessageAuthorDetails = self.controller.getContactDetails(message.quotedMessage.`from`)

      var communityChats: seq[ChatDto]
      if chatDetails.communityId != "":
        communityChats = self.controller.getCommunityById(chatDetails.communityId).chats

      var renderedMessageText = self.controller.getRenderedText(message.parsedText, communityChats)

      # Add image to album if album already exists
      if (message.contentType == ContentType.Image and len(message.albumId) != 0):
        if (self.view.model().updateAlbumIfExists(message.albumId, message.image, message.id)):
          continue

        if (self.updateItemsByAlbum(viewItems, message)):
          continue

      var transactionContract = message.transactionParameters.contract
      var transactionValue = message.transactionParameters.value
      var isCurrentUser = sender.isCurrentUser
      if(message.contentType == ContentType.Transaction):
        (transactionContract, transactionValue) = self.controller.getTransactionDetails(message)
        if message.transactionParameters.fromAddress != "":
          isCurrentUser = self.currentUserWalletContainsAddress(message.transactionParameters.fromAddress)
      var item = initItem(
        message.id,
        message.communityId,
        message.responseTo,
        message.`from`,
        sender.defaultDisplayName,
        sender.optionalName,
        sender.icon,
        sender.colorHash,
        (isCurrentUser and message.contentType != ContentType.DiscordMessage),
        sender.dto.added,
        message.outgoingStatus,
        renderedMessageText,
        message.text,
        message.parsedText,
        message.image,
        message.containsContactMentions(),
        message.seen,
        timestamp = message.timestamp,
        clock = message.clock,
        message.contentType,
        message.messageType,
        message.contactRequestState,
        sticker = message.sticker.url,
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
        message.mentionedUsersPks(),
        sender.dto.trustStatus,
        sender.dto.ensVerified,
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

      for r in reactions:
        if(r.messageId == message.id):
          var emojiIdAsEnum: EmojiId
          if(message_reaction_item.toEmojiIdAsEnum(r.emojiId, emojiIdAsEnum)):
            let userWhoAddedThisReaction = self.controller.getContactById(r.`from`)
            let didIReactWithThisEmoji = userWhoAddedThisReaction.id == singletonInstance.userProfile.getPubKey()
            item.addReaction(emojiIdAsEnum, didIReactWithThisEmoji, userWhoAddedThisReaction.id,
            userWhoAddedThisReaction.userDefaultDisplayName(), r.id)
          else:
            error "wrong emoji id found when loading messages", methodName="newMessagesLoaded"

      if message.editedAt != 0:
        item.isEdited = true

      if(message.contentType == ContentType.Gap):
        item.gapFrom = message.gapParameters.`from`
        item.gapTo = message.gapParameters.to

      # messages are sorted from the most recent to the least recent one
      viewItems.add(item)

    if self.controller.getChatDetails().hasMoreMessagesToRequest():
      viewItems.add(self.createFetchMoreMessagesItem())
    viewItems.add(self.createChatIdentifierItem())
    self.view.model().removeItem(FETCH_MORE_MESSAGES_MESSAGE_ID)
    self.view.model().removeItem(CHAT_IDENTIFIER_MESSAGE_ID)
    # Add new loaded messages
    self.view.model().insertItemsBasedOnClock(viewItems)
    self.view.model().resetNewMessagesMarker()

    # check if this loading was caused by the click on a messages from the app search result
    self.checkIfMessageLoadedAndScrollToItIfItIs()

  self.initialMessagesLoaded = true
  self.reevaluateViewLoadingState()

method newPinnedMessagesLoaded*(self: Module, pinnedMessages: seq[PinnedMessageDto]) =
  for p in pinnedMessages:
    self.onPinMessage(p.message.id, p.pinnedBy)

method messagesAdded*(self: Module, messages: seq[MessageDto]) =
  var items: seq[Item]

  for message in messages:
    let sender = self.controller.getContactDetails(message.`from`)
    let chatDetails = self.controller.getChatDetails()
    let communityChats = self.controller.getCommunityById(chatDetails.communityId).chats
    var quotedMessageAuthorDetails = ContactDetails()
    if message.quotedMessage.`from` != "":
      if(message.`from` == message.quotedMessage.`from`):
        quotedMessageAuthorDetails = sender
      else:
        quotedMessageAuthorDetails = self.controller.getContactDetails(message.quotedMessage.`from`)

    let renderedMessageText = self.controller.getRenderedText(message.parsedText, communityChats)

    var transactionContract = message.transactionParameters.contract
    var transactionValue = message.transactionParameters.value
    var isCurrentUser = sender.isCurrentUser
    if message.contentType == ContentType.Transaction:
      (transactionContract, transactionValue) = self.controller.getTransactionDetails(message)
      if message.transactionParameters.fromAddress != "":
        isCurrentUser = self.currentUserWalletContainsAddress(message.transactionParameters.fromAddress)
    # remove a message which has replace parameters filled
    let index = self.view.model().findIndexForMessageId(message.replace)
    if(index != -1):
      self.view.model().removeItem(message.replace)

    # https://github.com/status-im/status-desktop/issues/7632 will introduce deleteFroMe feature.
    # Now we just skip deleted messages
    if message.deleted or message.deletedForMe:
      continue

    # Add image to album if album already exists
    if (message.contentType == ContentType.Image and len(message.albumId) != 0):
      if (self.view.model().updateAlbumIfExists(message.albumId, message.image, message.id)):
        continue
      
      if (self.updateItemsByAlbum(items, message)):
        continue

    var item = initItem(
      message.id,
      message.communityId,
      message.responseTo,
      message.`from`,
      sender.defaultDisplayName,
      sender.optionalName,
      sender.icon,
      sender.colorHash,
      (isCurrentUser and message.contentType != ContentType.DiscordMessage),
      sender.dto.added,
      message.outgoingStatus,
      renderedMessageText,
      message.text,
      message.parsedText,
      message.image,
      message.containsContactMentions(),
      message.seen,
      timestamp = message.timestamp,
      clock = message.clock,
      message.contentType,
      message.messageType,
      message.contactRequestState,
      sticker = message.sticker.url,
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
      sender.dto.trustStatus,
      sender.dto.ensVerified,
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
    items.add(item)

  self.view.model().insertItemsBasedOnClock(items)

method removeNewMessagesMarker*(self: Module)

method onSendingMessageSuccess*(self: Module, message: MessageDto) =
  self.messagesAdded(@[message])
  self.view.emitSendingMessageSuccessSignal()
  self.removeNewMessagesMarker()

method onSendingMessageError*(self: Module) =
  self.view.emitSendingMessageErrorSignal()

method onEnvelopeSent*(self: Module, messagesIds: seq[string]) =
  for messageId in messagesIds:
    self.view.model().itemSent(messageId)

method onEnvelopeExpired*(self: Module, messagesIds: seq[string]) =
  for messageId in messagesIds:
    self.view.model().itemExpired(messageId)

method onMessageDelivered*(self: Module, messageId: string) =
  self.view.model().itemDelivered(messageId)

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
      userWhoAddedThisReaction.id, userWhoAddedThisReaction.userDefaultDisplayName(), reactionId)
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

method getChatIcon*(self: Module): string =
  let chatDto = self.controller.getChatDetails()
  return chatDto.icon

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
    if item.senderId == contactId:
      item.senderDisplayName = updatedContact.defaultDisplayName
      item.senderOptionalName = updatedContact.optionalName
      item.senderIcon = updatedContact.icon
      item.senderColorHash = updatedContact.colorHash
      item.senderIsAdded = updatedContact.dto.added
      item.senderTrustStatus = updatedContact.dto.trustStatus
      item.senderEnsVerified = updatedContact.dto.ensVerified

    if item.quotedMessageAuthorDetails.dto.id == contactId:
      item.quotedMessageAuthorDetails = updatedContact
      item.quotedMessageAuthorDisplayName = updatedContact.defaultDisplayName
      item.quotedMessageAuthorAvatar = updatedContact.icon

    if item.messageContainsMentions and item.mentionedUsersPks.anyIt(it == contactId):
      let chatDetails = self.controller.getChatDetails()
      let communityChats = self.controller.getCommunityById(chatDetails.communityId).chats
      item.messageText = self.controller.getRenderedText(item.parsedText, communityChats)

method deleteMessage*(self: Module, messageId: string) =
  self.controller.deleteMessage(messageId)

method onMessageDeleted*(self: Module, messageId: string) =
  self.view.model().removeItem(messageId)

method editMessage*(self: Module, messageId: string, contentType: int, updatedMsg: string) =
  self.controller.editMessage(messageId, contentType, updatedMsg)

method onMessageEdited*(self: Module, message: MessageDto) =
  let itemBeforeChange = self.view.model().getItemWithMessageId(message.id)
  if(itemBeforeChange.isNil):
    return

  let mentionedUsersPks = itemBeforeChange.mentionedUsersPks
  let chatDetails = self.controller.getChatDetails()
  let communityChats = self.controller.getCommunityById(chatDetails.communityId).chats

  self.view.model().updateEditedMsg(
    message.id,
    self.controller.getRenderedText(message.parsedText, communityChats),
    message.text,
    message.parsedText,
    message.contentType,
    message.mentioned,
    message.containsContactMentions(),
    message.links,
    message.mentionedUsersPks
    )

method onHistoryCleared*(self: Module) =
  self.view.model().clear()

method updateChatIdentifier*(self: Module) =
  let chatDto = self.controller.getChatDetails()
  self.setChatDetails(chatDto)
  # Delete the old ChatIdentifier message first
  self.view.model().removeItem(CHAT_IDENTIFIER_MESSAGE_ID)
  # Add new loaded messages
  self.view.model().insertItemBasedOnClock(self.createChatIdentifierItem())

method updateChatFetchMoreMessages*(self: Module) =
  self.view.model().removeItem(FETCH_MORE_MESSAGES_MESSAGE_ID)

  if (self.controller.getChatDetails().hasMoreMessagesToRequest()):
    self.view.model().insertItemBasedOnClock(self.createFetchMoreMessagesItem())

method getLinkPreviewData*(self: Module, link: string, uuid: string, whiteListedSites: string, whiteListedImgExtensions: string, unfurlImages: bool): string =
  return self.controller.getLinkPreviewData(link, uuid, whiteListedSites, whiteListedImgExtensions, unfurlImages)

method onPreviewDataLoaded*(self: Module, previewData: string, uuid: string) =
  self.view.onPreviewDataLoaded(previewData, uuid)

proc switchToMessage*(self: Module, messageId: string) =
  let index = self.view.model().findIndexForMessageId(messageId)
  if(index != -1):
    self.controller.clearSearchedMessageId()
    self.view.emitSwitchToMessageSignal(index)
  else:
    self.controller.setSearchedMessageId(messageId)

method scrollToMessage*(self: Module, messageId: string) =
  if(messageId == ""):
    return

  if(self.view.getMessageSearchOngoing()):
    return

  self.view.setMessageSearchOngoing(true)
  self.controller.setSearchedMessageId(messageId)
  self.checkIfMessageLoadedAndScrollToItIfItIs()
  self.reevaluateViewLoadingState()

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

method onMailserverSynced*(self: Module, syncedFrom: int64) =
  let chatDto = self.controller.getChatDetails()
  if (not chatDto.hasMoreMessagesToRequest(syncedFrom)):
    self.view.model().removeItem(FETCH_MORE_MESSAGES_MESSAGE_ID)

method resendChatMessage*(self: Module, messageId: string): string =
  return self.controller.resendChatMessage(messageId)

method resetNewMessagesMarker*(self: Module) =
  self.firstUnseenMessageState.fetching = true
  self.firstUnseenMessageState.scrollToWhenFetched = false
  self.controller.getAsyncFirstUnseenMessageId()

method resetAndScrollToNewMessagesMarker*(self: Module) =
  self.firstUnseenMessageState.fetching = true
  self.firstUnseenMessageState.scrollToWhenFetched = true
  self.controller.getAsyncFirstUnseenMessageId()

method removeNewMessagesMarker*(self: Module) =
  self.view.model().setFirstUnseenMessageId("")
  self.view.model().resetNewMessagesMarker()

method markAllMessagesRead*(self: Module) =
  self.view.model().markAllAsSeen()

method markMessagesAsRead*(self: Module, messages: seq[string]) =
  self.view.model().markAsSeen(messages)

method updateCommunityDetails*(self: Module, community: CommunityDto) =
  self.view.setAmIChatAdmin(community.admin)
  self.view.setIsPinMessageAllowedForMembers(community.adminSettings.pinMessageAllMembersEnabled)

proc setChatDetails(self: Module, chatDetails: ChatDto) =
  self.view.setChatColor(chatDetails.color)
  self.view.setChatIcon(chatDetails.icon)
  self.view.setChatType(chatDetails.chatType.int)

proc updateItemsByAlbum(self: Module, items: var seq[Item], message: MessageDto): bool =
  for i in 0 ..< items.len:
    let item = items[i]
    if item.albumId == message.albumId:
      # Check if message already in album
      for j in 0 ..< item.albumMessageIds.len:
        if item.albumMessageIds[j] == message.id:
          return true
        
        var albumImages = item.albumMessageImages
        var albumMessagesIds = item.albumMessageIds
        albumMessagesIds.add(message.id)
        albumImages.add(message.image)
        item.albumMessageImages = albumImages
        item.albumMessageIds = albumMessagesIds
        items[i] = item
        return true
  return false

method isFirstUnseenMessageInitialized*(self: Module): bool =
  return self.firstUnseenMessageState.initialized

method onFirstUnseenMessageLoaded*(self: Module, messageId: string) =
  self.view.model().setFirstUnseenMessageId(messageId)
  self.view.model().resetNewMessagesMarker()
  if self.firstUnseenMessageState.scrollToWhenFetched:
    self.scrollToMessage(messageId)
  self.firstUnseenMessageState.initialized = true
  self.firstUnseenMessageState.fetching = false
  self.reevaluateViewLoadingState()
