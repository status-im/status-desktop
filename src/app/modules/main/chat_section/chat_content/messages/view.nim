import NimQml, json
import ../../../../shared_models/message_model
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      initialMessagesLoaded: bool
      loadingHistoryMessagesInProgress: bool

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
    
  proc getChatType*(self: View): int {.slot.} =
    return self.delegate.getChatType()

  proc getChatColor*(self: View): string {.slot.} =
    return self.delegate.getChatColor()

  proc amIChatAdmin*(self: View): bool {.slot.} =
    return self.delegate.amIChatAdmin()

  proc pinMessageAllowedForMembers*(self: View): bool {.slot.} =
    return self.delegate.pinMessageAllowedForMembers()

  proc getNumberOfPinnedMessages*(self: View): int {.slot.} =
    return self.delegate.getNumberOfPinnedMessages()

  proc initialMessagesLoadedChanged*(self: View) {.signal.}

  proc getInitialMessagesLoaded*(self: View): bool {.slot.} =
    return self.initialMessagesLoaded

  QtProperty[bool] initialMessagesLoaded:
    read = getInitialMessagesLoaded
    notify = initialMessagesLoadedChanged

  proc initialMessagesAreLoaded*(self: View) = # this is not a slot
    if (self.initialMessagesLoaded):
      return
    self.initialMessagesLoaded = true
    self.initialMessagesLoadedChanged()

  proc loadingHistoryMessagesInProgressChanged*(self: View) {.signal.}

  proc getLoadingHistoryMessagesInProgress*(self: View): bool {.slot.} =
    return self.loadingHistoryMessagesInProgress

  QtProperty[bool] loadingHistoryMessagesInProgress:
    read = getLoadingHistoryMessagesInProgress
    notify = loadingHistoryMessagesInProgressChanged

  proc setLoadingHistoryMessagesInProgress*(self: View, value: bool) = # this is not a slot
    if (value == self.loadingHistoryMessagesInProgress):
      return
    self.loadingHistoryMessagesInProgress = value
    self.loadingHistoryMessagesInProgressChanged()

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

  proc editMessage*(self: View, messageId: string, updatedMsg: string) {.slot.} =
    self.delegate.editMessage(messageId, updatedMsg)

  proc getLinkPreviewData*(self: View, link: string, uuid: string): string {.slot.} =
    return self.delegate.getLinkPreviewData(link, uuid)

  proc linkPreviewDataWasReceived*(self: View, previewData: string) {.signal.}

  proc onPreviewDataLoaded*(self: View, previewData: string) {.slot.} =
    self.linkPreviewDataWasReceived(previewData)

  proc switchToMessage(self: View, messageIndex: int) {.signal.}
  proc emitSwitchToMessageSignal*(self: View, messageIndex: int) =
    self.switchToMessage(messageIndex)

  proc scrollToMessage(self: View, messageIndex: int) {.signal.}
  proc emitScrollToMessageSignal*(self: View, messageIndex: int) =
    self.scrollToMessage(messageIndex)

  proc scrollMessagesUp(self: View) {.signal.}
  proc emitScrollMessagesUpSignal*(self: View) =
    self.scrollMessagesUp()

  proc requestMoreMessages(self: View) {.slot.} =
    self.delegate.requestMoreMessages()

  proc fillGaps(self: View, messageId: string) {.slot.} =
    self.delegate.fillGaps(messageId)

  proc leaveChat*(self: View) {.slot.} =
    self.delegate.leaveChat()

  proc refreshAMessageUserRespondedTo(self: View, msgId: string) {.signal.}
  proc emitRefreshAMessageUserRespondedToSignal*(self: View, msgId: string) =
    self.refreshAMessageUserRespondedTo(msgId)