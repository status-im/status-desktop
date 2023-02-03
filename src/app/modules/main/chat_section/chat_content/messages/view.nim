import NimQml, json
import ../../../../shared_models/message_model
import ../../../../shared_models/message_item
import ../../../../../../app_service/service/chat/dto/chat
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      initialMessagesLoaded: bool
      messageSearchOngoing: bool
      amIChatAdmin: bool
      isPinMessageAllowedForMembers: bool
      chatColor: string
      chatIcon: string
      chatType: int

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.initialMessagesLoaded = false
    result.messageSearchOngoing = false
    result.amIChatAdmin = false
    result.isPinMessageAllowedForMembers = false
    result.chatColor = ""
    result.chatIcon = ""
    result.chatType = ChatType.Unknown.int


  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc model*(self: View): Model =
    return self.model

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant
  QtProperty[QVariant] model:
    read = getModel

  proc toggleReaction*(self: View, messageId: string, emojiId: int) {.slot.} =
    self.delegate.toggleReaction(messageId, emojiId)

  proc pinMessage*(self: View, messageId: string) {.slot.} =
    self.delegate.pinUnpinMessage(messageId, true)

  proc unpinMessage*(self: View, messageId: string) {.slot.} =
    self.delegate.pinUnpinMessage(messageId, false)

  proc getMessageByIdAsJson*(self: View, messageId: string): string {.slot.} =
    let jsonObj = self.model.getMessageByIdAsJson(messageId)
    if(jsonObj.isNil):
      return ""
    return $jsonObj

  proc getMessageByIndexAsJson*(self: View, index: int): string {.slot.} =
    let jsonObj = self.model.getMessageByIndexAsJson(index)
    if(jsonObj.isNil):
      return ""
    return $jsonObj

  proc getSectionId*(self: View): string {.slot.} =
    return self.delegate.getSectionId()

  proc getChatId*(self: View): string {.slot.} =
    return self.delegate.getChatId()

  proc getNumberOfPinnedMessages*(self: View): int {.slot.} =
    return self.delegate.getNumberOfPinnedMessages()

  proc initialMessagesLoadedChanged*(self: View) {.signal.}

  proc getInitialMessagesLoaded(self: View): bool {.slot.} =
    return self.initialMessagesLoaded

  QtProperty[bool] initialMessagesLoaded:
    read = getInitialMessagesLoaded
    notify = initialMessagesLoadedChanged

  proc initialMessagesAreLoaded*(self: View) = # this is not a slot
    if (self.initialMessagesLoaded):
      return
    self.initialMessagesLoaded = true
    self.initialMessagesLoadedChanged()

  proc loadMoreMessages*(self: View) {.slot.} =
    self.delegate.loadMoreMessages()

  proc messageSuccessfullySent*(self: View) {.signal.}
  proc emitSendingMessageSuccessSignal*(self: View) =
    self.messageSuccessfullySent()

  proc sendingMessageFailed*(self: View) {.signal.}

  proc emitSendingMessageErrorSignal*(self: View) =
    self.sendingMessageFailed()

  proc deleteMessage*(self: View, messageId: string) {.slot.} =
    self.delegate.deleteMessage(messageId)

  proc setEditModeOn*(self: View, messageId: string) {.slot.} =
   self.model.setEditModeOn(messageId)

  proc setEditModeOff*(self: View, messageId: string) {.slot.} =
   self.model.setEditModeOff(messageId)

  proc editMessage*(self: View, messageId: string, contentType: int, updatedMsg: string) {.slot.} =
    self.delegate.editMessage(messageId, contentType, updatedMsg)

  proc getLinkPreviewData*(self: View, link: string, uuid: string, whiteListedSites: string, whiteListedImgExtensions: string, unfurlImages: bool): string {.slot.} =
    return self.delegate.getLinkPreviewData(link, uuid, whiteListedSites, whiteListedImgExtensions, unfurlImages)

  proc linkPreviewDataWasReceived*(self: View, previewData: string, uuid: string) {.signal.}

  proc onPreviewDataLoaded*(self: View, previewData: string, uuid: string) {.slot.} =
    self.linkPreviewDataWasReceived(previewData, uuid)

  proc switchToMessage(self: View, messageIndex: int) {.signal.}
  proc emitSwitchToMessageSignal*(self: View, messageIndex: int) =
    self.switchToMessage(messageIndex)

  proc scrollToMessage(self: View, messageIndex: int) {.signal.}
  proc emitScrollToMessageSignal*(self: View, messageIndex: int) =
    self.scrollToMessage(messageIndex)

  proc requestMoreMessages(self: View) {.slot.} =
    self.delegate.requestMoreMessages()

  proc fillGaps(self: View, messageId: string) {.slot.} =
    self.delegate.fillGaps(messageId)

  proc leaveChat*(self: View) {.slot.} =
    self.delegate.leaveChat()

  proc jumpToMessage*(self: View, messageId: string) {.slot.} =
    self.delegate.scrollToMessage(messageId)

  proc setEditModeOnAndScrollToLastMessage*(self: View, pubkey: string) {.slot.} =
    let lastMessage = self.model.getLastItemFrom(pubKey)
    if lastMessage != nil and lastMessage.id != "":
      self.model.setEditModeOn(lastMessage.id)
      self.jumpToMessage(lastMessage.id)

  proc resendMessage*(self: View, messageId: string) {.slot.} =
    let error = self.delegate.resendChatMessage(messageId)
    if (error != ""):
      self.model.itemFailedResending(messageId, error)
      return
    self.model.itemSending(messageId)

  proc messageSearchOngoingChanged*(self: View) {.signal.}
  proc getMessageSearchOngoing*(self: View): bool {.slot.} =
    return self.messageSearchOngoing

  QtProperty[bool] messageSearchOngoing:
    read = getMessageSearchOngoing
    notify = messageSearchOngoingChanged

  proc setMessageSearchOngoing*(self: View, value: bool) =
    self.messageSearchOngoing = value
    self.messageSearchOngoingChanged()

  proc addNewMessagesMarker*(self: View) {.slot.} =
    if self.model.newMessagesMarkerIndex() == -1:
      self.delegate.resetNewMessagesMarker()

  proc amIChatAdminChanged*(self: View) {.signal.}
  proc getAmIChatAdmin*(self: View): bool {.slot.} =
    return self.amIChatAdmin
  
  QtProperty[bool] amIChatAdmin:
    read = getAmIChatAdmin
    notify = amIChatAdminChanged
  
  proc setAmIChatAdmin*(self: View, value: bool) =
    self.amIChatAdmin = value
    self.amIChatAdminChanged()

  proc isPinMessageAllowedForMembersChanged*(self: View) {.signal.}
  proc getIsPinMessageAllowedForMembers*(self: View): bool {.slot.} =
    return self.isPinMessageAllowedForMembers
  
  QtProperty[bool] isPinMessageAllowedForMembers:
    read = getIsPinMessageAllowedForMembers
    notify = isPinMessageAllowedForMembersChanged
  
  proc setIsPinMessageAllowedForMembers*(self: View, value: bool) =
    self.isPinMessageAllowedForMembers = value
    self.isPinMessageAllowedForMembersChanged()

  proc chatColorChanged*(self: View) {.signal.}
  proc getChatColor*(self: View): string {.slot.} =
    return self.chatColor

  QtProperty[string] chatColor:
    read = getChatColor
    notify = chatColorChanged
  
  proc setChatColor*(self: View, value: string) =
    self.chatColor = value
    self.chatColorChanged()

  proc chatIconChanged*(self: View) {.signal.}
  proc getChatIcon*(self: View): string {.slot.} =
    return self.chatIcon

  QtProperty[string] chatIcon:
    read = getChatIcon
    notify = chatIconChanged
  
  proc setChatIcon*(self: View, value: string) =
    self.chatIcon = value
    self.chatIconChanged()
  
  proc chatTypeChanged*(self: View) {.signal.}
  proc getChatType*(self: View): int {.slot.} =
    return self.chatType

  QtProperty[int] chatType:
    read = getChatType
    notify = chatTypeChanged
  
  proc setChatType*(self: View, value: int) =
    self.chatType = value
    self.chatTypeChanged()