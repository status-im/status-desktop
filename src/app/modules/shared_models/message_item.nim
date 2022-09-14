import json, strformat
import ../../../app_service/common/types
import ../../../app_service/service/contacts/dto/contacts

export types.ContentType
import message_reaction_model, message_reaction_item, message_transaction_parameters_item

## An explanation why we keep track of `timestamp` and `localTimestamp` here
## 
## introduction of those two actually fixes the following issues:
## https://github.com/status-im/status-desktop/issues/6004
## https://github.com/status-im/status-desktop/issues/7058
##
## We should always refer to `whisperTimestamp` as it is set for a message by the network
## in order they are sent (that solves the issue #6004), but another issue #7058 is happening
## cause `whisperTimestamp` has one second accuracy (which is a very big timeframe for messages). 
## That further means that all messsages sent by user A within 1000ms will be received with the 
## same `whisperTimestamp` value on the side of user B, in that case to differ the order of 
## those message we're using localy set `timestamp` on the sender side which is received unchanged
## on the receiver side. 
## Now a question why don't we use only locally set `timestamp` may araise... the answer is...
## because of issue #6004, cause it can be that users A and B send a message in almost the same 
## time in that case message sent by user A will be immediatelly added to the message list, while
## message sent by user B will arrive like a less then a second later and in that case user A may
## see user B message before or after his message and the same for user B, depends on local time 
## of those 2 users which is set for `timestamp` time in the moment they sent a message.
##
## If we anyhow find a way to have here accutacy higher than 1 second, then we can go on only
## with `whisperTimestamp`
## https://github.com/status-im/status-go/blob/3f987cc565091327f017bfe674c08ed01e301d00/protocol/messenger.go#L3726


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
    localTimestamp: int64
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
    senderEnsVerified: bool

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
    timestamp: int64, # whisper timestamp, with 1s accuracy (even accuracy looks like 1ms, last 3 digits are always 0)
    localTimestamp: int64, # local timestamp obtained when a message is being sent, with 1ms accuracy
    contentType: ContentType,
    messageType: int,
    sticker: string,
    stickerPack: int,
    links: seq[string],
    transactionParameters: TransactionParametersItem,
    mentionedUsersPks: seq[string],
    senderTrustStatus: TrustStatus,
    senderEnsVerified: bool
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
  result.localTimestamp = localTimestamp
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
  result.senderEnsVerified = senderEnsVerified

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
    messageText:{self.messageText},
    messageContainsMentions:{self.messageContainsMentions},
    timestamp:{$self.timestamp},
    localTimestamp:{$self.localTimestamp}
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

proc localTimestamp*(self: Item): int64 {.inline.} =
  self.localTimestamp

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
    "localTimestamp": self.localTimestamp,
    "contentType": self.contentType.int,
    "messageType": self.messageType,
    "pinned": self.pinned,
    "pinnedBy": self.pinnedBy,
    "editMode": self.editMode,
    "isEdited": self.isEdited,
    "links": self.links,
    "mentionedUsersPks": self.mentionedUsersPks,
    "senderEnsVerified": self.senderEnsVerified
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

