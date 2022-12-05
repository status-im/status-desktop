import json, strformat, strutils
import ../../../app_service/common/types
import ../../../app_service/service/contacts/dto/contacts
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
    seen: bool
    outgoingStatus: string
    messageText: string
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

proc initItem*(
    id,
    communityId,
    responseToMessageWithId,
    senderId,
    senderDisplayName,
    senderOptionalName,
    senderIcon: string,
    amISender: bool,
    senderIsAdded: bool,
    outgoingStatus,
    text,
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
    resendError: string
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
  result.seen = seen
  result.outgoingStatus = outgoingStatus
  result.messageText = if ContentType.Image == contentType: "" else: text
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

  if ContentType.DiscordMessage == contentType:
    if result.messageText == "":
      result.messageText = discordMessage.content
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

proc initNewMessagesMarkerItem*(timestamp: int64): Item =
  return initItem(
    id = "",
    communityId = "",
    responseToMessageWithId = "",
    senderId = "",
    senderDisplayName = "",
    senderOptionalName = "",
    senderIcon = "",
    amISender = false,
    senderIsAdded = false,
    outgoingStatus = "",
    text = "",
    image = "",
    messageContainsMentions = false,
    seen = true,
    timestamp = timestamp,
    clock = 0,
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
    resendError = ""
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
    messageContainsMentions:{self.messageContainsMentions},
    timestamp:{$self.timestamp},
    contentType:{$self.contentType.int},
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

proc messageImage*(self: Item): string {.inline.} =
  self.messageImage

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
    "seen": self.seen,
    "outgoingStatus": self.outgoingStatus,
    "messageText": self.messageText,
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
    "resendError": self.resendError
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

