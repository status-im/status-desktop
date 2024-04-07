import NimQml, sets
import ./io_interface
import ./preserved_properties
import ./urls_model
import ../../../../../../app/modules/shared_models/link_preview_model as link_preview_model
import ../../../../../../app/modules/shared_models/emoji_reactions_model as emoji_reactions_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      preservedProperties: PreservedProperties
      preservedPropertiesVariant: QVariant
      linkPreviewModel: link_preview_model.Model
      linkPreviewModelVariant: QVariant
      urlsModel: urls_model.Model
      urlsModelVariant: QVariant
      askToEnableLinkPreview: bool
      emojiReactionsModel: emoji_reactions_model.Model
      emojiReactionsModelVariant: QVariant

  proc delete*(self: View) =
    self.QObject.delete
    self.preservedPropertiesVariant.delete
    self.preservedProperties.delete
    self.linkPreviewModelVariant.delete
    self.linkPreviewModel.delete
    self.urlsModelVariant.delete
    self.urlsModel.delete
    self.emojiReactionsModel.delete
    self.emojiReactionsModelVariant.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.preservedProperties = newPreservedProperties()
    result.preservedPropertiesVariant = newQVariant(result.preservedProperties)
    result.linkPreviewModel = newLinkPreviewModel()
    result.linkPreviewModelVariant = newQVariant(result.linkPreviewModel)
    result.urlsModel = newUrlsModel()
    result.urlsModelVariant = newQVariant(result.urlsModel)
    result.askToEnableLinkPreview = false
    result.emojiReactionsModel = newEmojiReactionsModel()
    result.emojiReactionsModelVariant = newQVariant(result.emojiReactionsModel)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc sendMessage*(
      self: View,
      msg: string,
      replyTo: string,
      contentType: int) {.slot.} =
    # FIXME: Update this when `setText` is async.
    self.delegate.setText(msg, false)
    self.delegate.sendChatMessage(msg, replyTo, contentType, self.linkPreviewModel.getUnfuledLinkPreviews())

  proc sendImages*(self: View, imagePathsAndDataJson: string, msg: string, replyTo: string): string {.slot.} =
    # FIXME: Update this when `setText` is async.
    self.delegate.setText(msg, false)
    self.delegate.sendImages(imagePathsAndDataJson, msg, replyTo, self.linkPreviewModel.getUnfuledLinkPreviews())

  proc acceptAddressRequest*(self: View, messageId: string , address: string) {.slot.} =
    self.delegate.acceptRequestAddressForTransaction(messageId, address)

  proc declineAddressRequest*(self: View, messageId: string) {.slot.} =
    self.delegate.declineRequestAddressForTransaction(messageId)

  proc requestAddress*(self: View, fromAddress: string, amount: string, tokenAddress: string) {.slot.} =
    self.delegate.requestAddressForTransaction(fromAddress, amount, tokenAddress)

  proc request*(self: View, fromAddress: string, amount: string, tokenAddress: string) {.slot.} =
    self.delegate.requestTransaction(fromAddress, amount, tokenAddress)

  proc declineRequest*(self: View, messageId: string) {.slot.} =
    self.delegate.declineRequestTransaction(messageId)

  proc acceptRequestTransaction*(self: View, transactionHash: string, messageId: string, signature: string) {.slot.} =
    self.delegate.acceptRequestTransaction(transactionHash, messageId, signature)

  proc getPreservedProperties(self: View): QVariant {.slot.} =
    return self.preservedPropertiesVariant

  QtProperty[QVariant] preservedProperties:
    read = getPreservedProperties

  proc getLinkPreviewModel*(self: View): QVariant {.slot.} =
    return self.linkPreviewModelVariant

  QtProperty[QVariant] linkPreviewModel:
    read = getLinkPreviewModel

  proc askToEnableLinkPreviewChanged(self: View) {.signal.}
  proc getAskToEnableLinkPreview(self: View): bool {.slot.} =
    return self.askToEnableLinkPreview
  proc setAskToEnableLinkPreview*(self: View, value: bool) {.slot.} =
    self.askToEnableLinkPreview = value
    self.askToEnableLinkPreviewChanged()

  QtProperty[bool] askToEnableLinkPreview:
    read = getAskToEnableLinkPreview
    notify = askToEnableLinkPreviewChanged
    
  # Currently used to fetch link previews, but could be used elsewhere
  proc setText*(self: View, text: string) {.slot.} =
    self.delegate.setText(text, true)

  proc getPlainText*(self: View): string {.slot.} =
    return plain_text(self.preservedProperties.getText())

  proc updateLinkPreviewsFromCache*(self: View, urls: seq[string]) =
    let linkPreviews = self.delegate.linkPreviewsFromCache(urls)
    self.linkPreviewModel.updateLinkPreviews(linkPreviews)
    
    for contactId in self.linkPreviewModel.getContactIds().items:
      let contact = self.delegate.getContactDetails(contactId)
      if contact.dto.displayName != "":
        self.linkPreviewModel.setContactInfo(contact)

  proc setLinkPreviewUrls*(self: View, urls: seq[string]) =
    self.linkPreviewModel.setUrls(urls)
    self.updateLinkPreviewsFromCache(urls)

  proc clearLinkPreviewCache*(self: View) {.slot.} =
    self.delegate.clearLinkPreviewCache()

  proc reloadLinkPreview(self: View, link: string) {.slot.} =
    self.delegate.loadLinkPreviews(@[link])
  
  proc loadLinkPreviews(self: View, links: seq[string]) =
    self.delegate.loadLinkPreviews(links)
  
  proc enableLinkPreview(self: View) {.slot.} =
    self.delegate.setLinkPreviewEnabled(true)
  
  proc disableLinkPreview(self: View) {.slot.} =
    self.delegate.setLinkPreviewEnabled(false)
  
  proc setLinkPreviewEnabledForCurrentMessage(self: View, enabled: bool) {.slot.} =
    self.delegate.setLinkPreviewEnabledForThisMessage(enabled)
    self.delegate.reloadUnfurlingPlan()

  proc removeLinkPreviewData*(self: View, index: int) {.slot.} =
    self.linkPreviewModel.removePreviewData(index)

  proc urlsModelChanged(self: View) {.signal.}
  proc getUrlsModel*(self: View): QVariant {.slot.} =
    return self.urlsModelVariant

  proc setUrls*(self: View, urls: seq[string]) =
    self.urlsModel.setUrls(urls)

  QtProperty[QVariant] urlsModel:
    read = getUrlsModel
    notify = urlsModelChanged
