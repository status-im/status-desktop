import NimQml, std/wrapnils
import ./message_item

QtObject:
  type MessageItem* = ref object of QObject
    messageItem*: message_item.Item

  proc setup(self: MessageItem) =
    self.QObject.setup

  proc delete*(self: MessageItem) =
    self.QObject.delete

  proc newMessageItem*(message: message_item.Item): MessageItem =
    new(result, delete)
    result.setup
    result.messageItem = message

  proc `$`*(self: MessageItem): string =
    result = $self.messageItem

  proc setMessageItem*(self: MessageItem, messageItem: message_item.Item) =
    self.messageItem = messageItem

  proc responseToMessageWithId*(self: MessageItem): string {.slot.} = result = ?.self.messageItem.responseToMessageWithId
  QtProperty[string] responseToMessageWithId:
    read = responseToMessageWithId

  proc senderId*(self: MessageItem): string {.slot.} = result = ?.self.messageItem.senderId
  QtProperty[string] senderId:
    read = senderId

  proc pinnedBy*(self: MessageItem): string {.slot.} = result = ?.self.messageItem.pinnedBy
  QtProperty[string] pinnedBy:
    read = pinnedBy

  proc senderTrustStatus*(self: MessageItem): int {.slot.} = 
    let trustStatus = ?.self.messageItem.senderTrustStatus
    return trustStatus.int

  QtProperty[int] senderTrustStatus:
    read = senderTrustStatus

  proc senderDisplayName*(self: MessageItem): string {.slot.} = result = ?.self.messageItem.senderDisplayName
  QtProperty[string] senderDisplayName:
    read = senderDisplayName

  proc senderLocalName*(self: MessageItem): string {.slot.} = result = ?.self.messageItem.senderLocalName
  QtProperty[string] senderLocalName:
    read = senderLocalName

  proc amISender*(self: MessageItem): bool {.slot.} = result = ?.self.messageItem.amISender
  QtProperty[bool] amISender:
    read = amISender

  proc senderIcon*(self: MessageItem): string {.slot.} = result = ?.self.messageItem.senderIcon
  QtProperty[string] senderIcon:
    read = senderIcon

  proc seen*(self: MessageItem): bool {.slot.} = result = ?.self.messageItem.seen
  QtProperty[bool] seen:
    read = seen

  proc outgoingStatus*(self: MessageItem): string {.slot.} = result = ?.self.messageItem.outgoingStatus
  QtProperty[string] outgoingStatus:
    read = outgoingStatus

  proc messageText*(self: MessageItem): string {.slot.} = result = ?.self.messageItem.messageText
  QtProperty[string] messageText:
    read = messageText

  proc messageImage*(self: MessageItem): string {.slot.} = result = ?.self.messageItem.messageImage
  QtProperty[string] messageImage:
    read = messageImage

  proc sticker*(self: MessageItem): string {.slot.} = result = ?.self.messageItem.sticker
  QtProperty[string] sticker:
    read = sticker

  proc stickerPack*(self: MessageItem): int {.slot.} = result = ?.self.messageItem.stickerPack
  QtProperty[int] stickerPack:
    read = stickerPack

  # Convert to int
  # proc gapFrom*(self: MessageItem): int64 {.slot.} = result = ?.self.messageItem.gapFrom
  # QtProperty[int64] gapFrom:
  #   read = gapFrom

  # proc gapTo*(self: MessageItem): int64 {.slot.} = result = ?.self.messageItem.gapTo
  # QtProperty[int64] gapTo:
  #   read = gapTo

  # proc timestamp*(self: MessageItem): int64 {.slot.} = result = ?.self.messageItem.timestamp
  # QtProperty[int64] timestamp:
  #   read = timestamp

  proc contentType*(self: MessageItem): int {.slot.} =
    if (self.messageItem.isNil): return 0
    result = self.messageItem.contentType.int
  QtProperty[int] contentType:
    read = contentType

  proc messageType*(self: MessageItem): int {.slot.} = result = ?.self.messageItem.messageType
  QtProperty[int] messageType:
    read = messageType

  # TODO find a way to pass reactions since they are not basic types (might need to be a Model)
  # proc reactions*(self: MessageItem): int {.slot.} = result = ?.self.messageItem.reactions
  # QtProperty[int] reactions:
  #   read = reactions

  # proc reactionIds*(self: MessageItem): int {.slot.} = result = ?.self.messageItem.reactionIds
  # QtProperty[int] reactionIds:
  #   read = reactionIds

  proc pinned*(self: MessageItem): bool {.slot.} = result = ?.self.messageItem.pinned
  QtProperty[bool] pinned:
    read = bool

  proc editMode*(self: MessageItem): bool {.slot.} = result = ?.self.messageItem.editMode
  QtProperty[bool] editMode:
    read = bool

  proc isEdited*(self: MessageItem): bool {.slot.} = result = ?.self.messageItem.isEdited
  QtProperty[bool] isEdited:
    read = bool

  # this is not the greatest approach, but aligns with the rest of the code
  proc communityId*(self: MessageItem): string {.slot.} = result = ?.self.messageItem.communityId
  QtProperty[string] communityId:
    read = communityId

  proc reactionsModel*(self: MessageItem): QVariant {.slot.} = result = newQVariant(?.self.messageItem.reactionsModel)
  QtProperty[QVariant] reactionsModel:
    read = reactionsModel
