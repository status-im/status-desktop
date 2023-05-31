import json, strformat, strutils
import ../../../app_service/common/types
import ../../../app_service/service/contacts/dto/contact_details
import ../../../app_service/service/message/dto/message

export types.ContentType
import message_reaction_model, message_reaction_item, message_transaction_parameters_item

type
  Item* = ref object
    id: string
    communityId: string
    responseToMessageWithId: string
    senderId: string
    senderDisplayName: string
    senderOptionalName: string
    amISender: bool
    senderIsAdded: bool
    senderIcon: string
    senderColorHash: string
    seen: bool
    outgoingStatus: string
    messageText: string
    unparsedText: string
    # Saving the parsed text property because we need it to getRenderedText when mentions change
    parsedText: seq[ParsedText]
    messageImage: string
    messageContainsMentions: bool
    sticker: string
    stickerPack: int
    gapFrom: int64
    gapTo: int64
    timestamp: int64
    clock: int64 # lamport timestamp - used for ordering
    contentType: ContentType
    messageType: int
    contactRequestState: int
    reactionsModel: MessageReactionModel
    pinned: bool
    pinnedBy: string
    editMode: bool
    isEdited: bool
    links: seq[string]
    transactionParameters: TransactionParametersItem
    mentionedUsersPks: seq[string]
    senderTrustStatus: TrustStatus
    senderEnsVerified: bool
    messageAttachments: seq[string]
    resendError: string
    mentioned: bool
    quotedMessageFrom: string
    quotedMessageText: string
    quotedMessageParsedText: string
    quotedMessageContentType: ContentType
    quotedMessageDeleted: bool
    quotedMessageAuthorDisplayName: string
    quotedMessageAuthorAvatar: string
    quotedMessageAuthorDetails: ContactDetails
    albumId: string
    albumMessageImages: seq[string]
    albumMessageIds: seq[string]
    albumImagesCount: int

proc initItem*(
    id,
    communityId,
    responseToMessageWithId,
    senderId,
    senderDisplayName,
    senderOptionalName,
    senderIcon: string,
    senderColorHash: string,
    amISender: bool,
    senderIsAdded: bool,
    outgoingStatus,
    text,
    unparsedText: string,
    parsedText: seq[ParsedText],
    image: string,
    messageContainsMentions,
    seen: bool,
    timestamp: int64,
    clock: int64,
    contentType: ContentType,
    messageType: int,
    contactRequestState: int,
    sticker: string,
    stickerPack: int,
    links: seq[string],
    transactionParameters: TransactionParametersItem,
    mentionedUsersPks: seq[string],
    senderTrustStatus: TrustStatus,
    senderEnsVerified: bool,
    discordMessage: DiscordMessage,
    resendError: string,
    mentioned: bool,
    quotedMessageFrom: string,
    quotedMessageText: string,
    quotedMessageParsedText: string,
    quotedMessageContentType: ContentType,
    quotedMessageDeleted: bool,
    quotedMessageDiscordMessage: DiscordMessage,
    quotedMessageAuthorDetails: ContactDetails,
    albumId: string,
    albumMessageImages: seq[string],
    albumMessageIds: seq[string],
    albumImagesCount: int,
    ): Item =
  result = Item()
  result.id = id
  result.communityId = communityId
  result.responseToMessageWithId = responseToMessageWithId
  result.senderId = senderId
  result.senderDisplayName = senderDisplayName
  result.senderOptionalName = senderOptionalName
  result.amISender = amISender
  result.senderIsAdded = senderIsAdded
  result.senderIcon = senderIcon
  result.senderColorHash = senderColorHash
  result.seen = seen
  result.outgoingStatus = outgoingStatus
  result.messageText = text
  result.unparsedText = unparsedText
  result.parsedText = parsedText
  result.messageImage = image
  result.messageContainsMentions = messageContainsMentions
  result.timestamp = timestamp
  result.clock = clock
  result.contentType = contentType
  result.messageType = messageType
  result.contactRequestState = contactRequestState
  result.pinned = false
  result.reactionsModel = newMessageReactionModel()
  result.sticker = sticker
  result.stickerPack = stickerPack
  result.editMode = false
  result.isEdited = false
  result.links = links
  result.transactionParameters = transactionParameters
  result.mentionedUsersPks = mentionedUsersPks
  result.gapFrom = 0
  result.gapTo = 0
  result.senderTrustStatus = senderTrustStatus
  result.senderEnsVerified = senderEnsVerified
  result.messageAttachments = @[]
  result.resendError = resendError
  result.mentioned = mentioned
  result.quotedMessageFrom = quotedMessageFrom
  result.quotedMessageText = quotedMessageText
  result.quotedMessageParsedText = quotedMessageParsedText
  result.quotedMessageContentType = quotedMessageContentType
  result.quotedMessageDeleted = quotedMessageDeleted
  result.quotedMessageAuthorDetails = quotedMessageAuthorDetails
  result.albumId = albumId
  result.albumMessageImages = albumMessageImages
  result.albumMessageIds = albumMessageIds
  result.albumImagesCount = albumImagesCount

  if quotedMessageContentType == ContentType.DiscordMessage:
    result.quotedMessageAuthorDisplayName = quotedMessageDiscordMessage.author.name
    result.quotedMessageAuthorAvatar = quotedMessageDiscordMessage.author.localUrl
    if result.quotedMessageAuthorAvatar == "":
      result.quotedMessageAuthorAvatar = quotedMessageDiscordMessage.author.avatarUrl
  else:
    result.quotedMessageAuthorDisplayName = quotedMessageAuthorDetails.dto.userDefaultDisplayName()
    result.quotedMessageAuthorAvatar = quotedMessageAuthorDetails.dto.image.thumbnail

  if contentType == ContentType.DiscordMessage:

    if result.messageText == "":
      result.messageText = discordMessage.content
      result.unparsedText = discordMessage.content
    result.senderId = discordMessage.author.id
    result.senderDisplayName = discordMessage.author.name
    result.senderIcon = discordMessage.author.localUrl
    result.timestamp = parseInt(discordMessage.timestamp)*1000

    if result.senderIcon == "":
      result.senderIcon = discordMessage.author.avatarUrl

    if discordMessage.timestampEdited != "":
      result.timestamp = parseInt(discordMessage.timestampEdited)*1000

    for attachment in discordMessage.attachments:
      if attachment.contentType.contains("image"):
        result.messageAttachments.add(attachment.localUrl)

proc initNewMessagesMarkerItem*(clock, timestamp: int64): Item =
  return initItem(
    id = "",
    communityId = "",
    responseToMessageWithId = "",
    senderId = "",
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
    timestamp = timestamp,
    clock = clock,
    ContentType.NewMessagesMarker,
    messageType = -1,
    contactRequestState = 0,
    sticker = "",
    stickerPack = -1,
    links = @[],
    transactionParameters = newTransactionParametersItem("","","","","","",-1,""),
    mentionedUsersPks = @[],
    senderTrustStatus = TrustStatus.Unknown,
    senderEnsVerified = false,
    discordMessage = DiscordMessage(),
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

proc `$`*(self: Item): string =
  result = fmt"""Item(
    id: {$self.id},
    communityId: {$self.communityId},
    responseToMessageWithId: {self.responseToMessageWithId},
    senderId: {self.senderId},
    senderDisplayName: {$self.senderDisplayName},
    senderOptionalName: {self.senderOptionalName},
    amISender: {$self.amISender},
    senderIsAdded: {$self.senderIsAdded},
    seen: {$self.seen},
    outgoingStatus:{$self.outgoingStatus},
    resendError:{$self.resendError},
    messageText:{self.messageText},
    unparsedText:{self.unparsedText},
    parsedText:{$self.parsedText},
    messageContainsMentions:{self.messageContainsMentions},
    timestamp:{$self.timestamp},
    contentType:{$self.contentType},
    messageType:{$self.messageType},
    contactRequestState:{$self.contactRequestState},
    pinned:{$self.pinned},
    pinnedBy:{$self.pinnedBy},
    messageReactions: [{$self.reactionsModel}],
    editMode:{$self.editMode},
    isEdited:{$self.isEdited},
    links:{$self.links},
    transactionParameters:{$self.transactionParameters},
    mentionedUsersPks:{$self.mentionedUsersPks},
    senderTrustStatus:{$self.senderTrustStatus},
    senderEnsVerified: {self.senderEnsVerified},
    )"""

proc id*(self: Item): string {.inline.} =
  self.id

proc communityId*(self: Item): string {.inline.} =
  self.communityId

proc responseToMessageWithId*(self: Item): string {.inline.} =
  self.responseToMessageWithId

proc senderId*(self: Item): string {.inline.} =
  self.senderId

proc senderDisplayName*(self: Item): string {.inline.} =
  self.senderDisplayName

proc `senderDisplayName=`*(self: Item, value: string) {.inline.} =
  self.senderDisplayName = value

proc senderOptionalName*(self: Item): string {.inline.} =
  self.senderOptionalName

proc `senderOptionalName=`*(self: Item, value: string) {.inline.} =
  self.senderOptionalName = value

proc senderIcon*(self: Item): string {.inline.} =
  self.senderIcon

proc `senderIcon=`*(self: Item, value: string) {.inline.} =
  self.senderIcon = value

proc senderColorHash*(self: Item): string {.inline.} =
  self.senderColorHash

proc `senderColorHash=`*(self: Item, value: string) {.inline.} =
  self.senderColorHash = value

proc amISender*(self: Item): bool {.inline.} =
  self.amISender

proc senderIsAdded*(self: Item): bool {.inline.} =
  self.senderIsAdded

proc `senderIsAdded=`*(self: Item, value: bool) {.inline.} =
  self.senderIsAdded = value

proc senderTrustStatus*(self: Item): TrustStatus {.inline.} =
  self.senderTrustStatus

proc `senderTrustStatus=`*(self: Item, value: TrustStatus) {.inline.} =
  self.senderTrustStatus = value

proc senderEnsVerified*(self: Item): bool {.inline.} =
  self.senderEnsVerified

proc `senderEnsVerified=`*(self: Item, value: bool) {.inline.} =
  self.senderEnsVerified = value

proc outgoingStatus*(self: Item): string {.inline.} =
  self.outgoingStatus

proc `outgoingStatus=`*(self: Item, value: string) {.inline.} =
  self.outgoingStatus = value

proc resendError*(self: Item): string {.inline.} =
  self.resendError

proc `resendError=`*(self: Item, value: string) {.inline.} =
  self.resendError = value

proc messageText*(self: Item): string {.inline.} =
  self.messageText

proc `messageText=`*(self: Item, value: string) {.inline.} =
  self.messageText = value

proc unparsedText*(self: Item): string {.inline.} =
  self.unparsedText

proc `unparsedText=`*(self: Item, value: string) {.inline.} =
  self.unparsedText = value

proc parsedText*(self: Item): seq[ParsedText] {.inline.} =
  self.parsedText

proc `parsedText=`*(self: Item, value: seq[ParsedText]) {.inline.} =
  self.parsedText = value

proc messageImage*(self: Item): string {.inline.} =
  self.messageImage

proc albumId*(self: Item): string {.inline.} =
  self.albumId

proc albumMessageImages*(self: Item): seq[string] {.inline.} =
  self.albumMessageImages

proc `albumMessageImages=`*(self: Item, value: seq[string]) {.inline.} =
  self.albumMessageImages = value

proc albumMessageIds*(self: Item): seq[string] {.inline.} =
  self.albumMessageIds

proc `albumMessageIds=`*(self: Item, value: seq[string]) {.inline.} =
  self.albumMessageIds = value

proc albumImagesCount*(self: Item): int {.inline.} = 
  self.albumImagesCount

proc messageContainsMentions*(self: Item): bool {.inline.} =
  self.messageContainsMentions

proc `messageContainsMentions=`*(self: Item, value: bool) {.inline.} =
  self.messageContainsMentions = value

proc stickerPack*(self: Item): int {.inline.} =
  self.stickerPack

proc sticker*(self: Item): string {.inline.} =
  self.sticker

proc seen*(self: Item): bool {.inline.} =
  self.seen

proc `seen=`*(self: Item, value: bool) {.inline.} =
  self.seen = value

proc timestamp*(self: Item): int64 {.inline.} =
  self.timestamp

proc clock*(self: Item): int64 {.inline.} =
  self.clock

proc contentType*(self: Item): ContentType {.inline.} =
  self.contentType

proc messageType*(self: Item): int {.inline.} =
  self.messageType

proc contactRequestState*(self: Item): int {.inline.} =
  self.contactRequestState

proc pinned*(self: Item): bool {.inline.} =
  self.pinned

proc `pinned=`*(self: Item, value: bool) {.inline.} =
  self.pinned = value

proc pinnedBy*(self: Item): string {.inline.} =
  self.pinnedBy

proc `pinnedBy=`*(self: Item, value: string) {.inline.} =
  self.pinnedBy = value

proc reactionsModel*(self: Item): MessageReactionModel {.inline.} =
  self.reactionsModel

proc shouldAddReaction*(self: Item, emojiId: EmojiId, userPublicKey: string): bool =
  return self.reactionsModel.shouldAddReaction(emojiId, userPublicKey)

proc getReactionId*(self: Item, emojiId: EmojiId, userPublicKey: string): string =
  return self.reactionsModel.getReactionId(emojiId, userPublicKey)

proc addReaction*(self: Item, emojiId: EmojiId, didIReactWithThisEmoji: bool, userPublicKey: string,
  userDisplayName: string, reactionId: string) =
  self.reactionsModel.addReaction(emojiId, didIReactWithThisEmoji, userPublicKey, userDisplayName, reactionId)

proc removeReaction*(self: Item, emojiId: EmojiId, reactionId: string, didIRemoveThisReaction: bool) =
  self.reactionsModel.removeReaction(emojiId, reactionId, didIRemoveThisReaction)

proc messageAttachments*(self: Item): seq[string] {.inline.} =
  self.messageAttachments

proc links*(self: Item): seq[string] {.inline.} =
  self.links

proc `links=`*(self: Item, links: seq[string]) {.inline.} =
  self.links = links

proc mentionedUsersPks*(self: Item): seq[string] {.inline.} =
  self.mentionedUsersPks

proc `mentionedUsersPks=`*(self: Item, mentionedUsersPks: seq[string]) {.inline.} =
  self.mentionedUsersPks = mentionedUsersPks

proc transactionParameters*(self: Item): TransactionParametersItem {.inline.} =
  self.transactionParameters

proc toJsonNode*(self: Item): JsonNode =
  result = %* {
    "id": self.id,
    "communityId": self.communityId,
    "responseToMessageWithId": self.responseToMessageWithId,
    "senderId": self.senderId,
    "senderDisplayName": self.senderDisplayName,
    "senderOptionalName": self.senderOptionalName,
    "amISender": self.amISender,
    "senderIsAdded": self.senderIsAdded,
    "senderIcon": self.senderIcon,
    "senderColorHash": self.senderColorHash,
    "seen": self.seen,
    "outgoingStatus": self.outgoingStatus,
    "messageText": self.messageText,
    "unparsedText": self.unparsedText,
    "messageImage": self.messageImage,
    "messageContainsMentions": self.messageContainsMentions,
    "sticker": self.sticker,
    "stickerPack": self.stickerPack,
    "gapFrom": self.gapFrom,
    "gapTo": self.gapTo,
    "timestamp": self.timestamp,
    "clock": self.clock,
    "contentType": self.contentType.int,
    "messageType": self.messageType,
    "contactRequestState": self.contactRequestState,
    "pinned": self.pinned,
    "pinnedBy": self.pinnedBy,
    "editMode": self.editMode,
    "isEdited": self.isEdited,
    "links": self.links,
    "mentionedUsersPks": self.mentionedUsersPks,
    "senderEnsVerified": self.senderEnsVerified,
    "resendError": self.resendError,
    "mentioned": self.mentioned,
    "quotedMessageFrom": self.quotedMessageFrom,
    "quotedMessageText": self.quotedMessageText,
    "quotedMessageParsedText": self.quotedMessageParsedText,
    "quotedMessageContentType": self.quotedMessageContentType.int,
    "quotedMessageDeleted": self.quotedMessageDeleted,
    "quotedMessageAuthorDisplayName": self.quotedMessageAuthorDisplayName,
    "quotedMessageAuthorAvatar": self.quotedMessageAuthorAvatar,
    "albumId": self.albumId,
    "albumMessageImages": self.albumMessageImages,
    "albumMessageIds": self.albumMessageIds,
    "albumImagesCount": self.albumImagesCount,
  }

proc editMode*(self: Item): bool {.inline.} =
  self.editMode

proc `editMode=`*(self: Item, value: bool) {.inline.} =
  self.editMode = value

proc isEdited*(self: Item): bool {.inline.} =
  self.isEdited

proc `isEdited=`*(self: Item, value: bool) {.inline.} =
  self.isEdited = value

proc gapFrom*(self: Item): int64 {.inline.} =
  self.gapFrom

proc `gapFrom=`*(self: Item, value: int64) {.inline.} =
  self.gapFrom = value

proc gapTo*(self: Item): int64 {.inline.} =
  self.gapTo

proc `gapTo=`*(self: Item, value: int64) {.inline.} =
  self.gapTo = value

proc mentioned*(self: Item): bool {.inline.} =
  self.mentioned

proc `mentioned=`*(self: Item, value: bool) {.inline.} =
  self.mentioned = value

proc quotedMessageFrom*(self: Item): string {.inline.} =
  self.quotedMessageFrom
proc `quotedMessageFrom=`*(self: Item, value: string) {.inline.} =
  self.quotedMessageFrom = value

proc quotedMessageText*(self: Item): string {.inline.} =
  self.quotedMessageText
proc `quotedMessageText=`*(self: Item, value: string) {.inline.} =
  self.quotedMessageText = value

proc quotedMessageParsedText*(self: Item): string {.inline.} =
  self.quotedMessageParsedText
proc `quotedMessageParsedText=`*(self: Item, value: string) {.inline.} =
  self.quotedMessageParsedText = value

proc quotedMessageContentType*(self: Item): ContentType {.inline.} =
  self.quotedMessageContentType
proc `quotedMessageContentType=`*(self: Item, value: ContentType) {.inline.} =
  self.quotedMessageContentType = value

proc quotedMessageDeleted*(self: Item): bool {.inline.} =
  self.quotedMessageDeleted
proc `quotedMessageDeleted=`*(self: Item, value: bool) {.inline.} =
  self.quotedMessageDeleted = value

proc quotedMessageAuthorDisplayName*(self: Item): string {.inline.} =
  self.quotedMessageAuthorDisplayName

proc `quotedMessageAuthorDisplayName=`*(self: Item, value: string) {.inline.} =
  self.quotedMessageAuthorDisplayName = value

proc quotedMessageAuthorAvatar*(self: Item): string {.inline.} =
  self.quotedMessageAuthorAvatar

proc `quotedMessageAuthorAvatar=`*(self: Item, value: string) {.inline.} =
  self.quotedMessageAuthorAvatar = value
  
proc quotedMessageAuthorDetails*(self: Item): ContactDetails {.inline.} =
  self.quotedMessageAuthorDetails
proc `quotedMessageAuthorDetails=`*(self: Item, value: ContactDetails) {.inline.} =
  self.quotedMessageAuthorDetails = value
