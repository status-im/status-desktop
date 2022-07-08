import json, strformat
import ../../../app_service/common/types
import ../../../app_service/service/contacts/dto/contacts

export types.ContentType
import message_reaction_model, message_reaction_item, message_transaction_parameters_item

type
  Item* = ref object
    id: string
    communityId: string
    responseToMessageWithId: string
    senderId: string
    senderDisplayName: string
    senderLocalName: string
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
    contentType: ContentType
    messageType: int
    reactionsModel: MessageReactionModel
    pinned: bool
    pinnedBy: string
    editMode: bool
    isEdited: bool
    links: seq[string]
    transactionParameters: TransactionParametersItem
    mentionedUsersPks: seq[string]
    senderTrustStatus: TrustStatus

proc initItem*(
    id,
    communityId,
    responseToMessageWithId,
    senderId,
    senderDisplayName,
    senderLocalName,
    senderIcon: string,
    amISender: bool,
    senderIsAdded: bool,
    outgoingStatus,
    text,
    image: string,
    messageContainsMentions,
    seen: bool,
    timestamp: int64,
    contentType: ContentType,
    messageType: int,
    sticker: string,
    stickerPack: int,
    links: seq[string],
    transactionParameters: TransactionParametersItem,
    mentionedUsersPks: seq[string],
    senderTrustStatus: TrustStatus
    ): Item =
  result = Item()
  result.id = id
  result.communityId = communityId
  result.responseToMessageWithId = responseToMessageWithId
  result.senderId = senderId
  result.senderDisplayName = senderDisplayName
  result.senderLocalName = senderLocalName
  result.amISender = amISender
  result.senderIsAdded = senderIsAdded
  result.senderIcon = senderIcon
  result.seen = seen
  result.outgoingStatus = outgoingStatus
  result.messageText = if ContentType.Image == contentType: "" else: text
  result.messageImage = image
  result.messageContainsMentions = messageContainsMentions
  result.timestamp = timestamp
  result.contentType = contentType
  result.messageType = messageType
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

proc `$`*(self: Item): string =
  result = fmt"""Item(
    id: {$self.id},
    communityId: {$self.communityId},
    responseToMessageWithId: {self.responseToMessageWithId},
    senderId: {self.senderId},
    senderDisplayName: {$self.senderDisplayName},
    senderLocalName: {self.senderLocalName},
    amISender: {$self.amISender},
    senderIsAdded: {$self.senderIsAdded},
    seen: {$self.seen},
    outgoingStatus:{$self.outgoingStatus},
    messageText:{self.messageText},
    messageContainsMentions:{self.messageContainsMentions},
    timestamp:{$self.timestamp},
    contentType:{$self.contentType.int},
    messageType:{$self.messageType},
    pinned:{$self.pinned},
    pinnedBy:{$self.pinnedBy},
    messageReactions: [{$self.reactionsModel}],
    editMode:{$self.editMode},
    isEdited:{$self.isEdited},
    links:{$self.links},
    transactionParameters:{$self.transactionParameters},
    mentionedUsersPks:{$self.mentionedUsersPks},
    senderTrustStatus:{$self.senderTrustStatus},
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

proc senderLocalName*(self: Item): string {.inline.} =
  self.senderLocalName

proc `senderLocalName=`*(self: Item, value: string) {.inline.} =
  self.senderLocalName = value

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

proc outgoingStatus*(self: Item): string {.inline.} =
  self.outgoingStatus

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

proc timestamp*(self: Item): int64 {.inline.} =
  self.timestamp

proc contentType*(self: Item): ContentType {.inline.} =
  self.contentType

proc messageType*(self: Item): int {.inline.} =
  self.messageType

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
    "senderLocalName": self.senderLocalName,
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
    "contentType": self.contentType.int,
    "messageType": self.messageType,
    "pinned": self.pinned,
    "pinnedBy": self.pinnedBy,
    "editMode": self.editMode,
    "isEdited": self.isEdited,
    "links": self.links,
    "mentionedUsersPks": self.mentionedUsersPks
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

