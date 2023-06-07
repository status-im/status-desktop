import NimQml, json

import io_interface
import app/modules/shared_models/social_links_model
import app/modules/shared_models/social_link_item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      socialLinksModel: SocialLinksModel
      socialLinksModelVariant: QVariant
      temporarySocialLinksModel: SocialLinksModel # used for editing purposes
      temporarySocialLinksModelVariant: QVariant

  proc delete*(self: View) =
    self.QObject.delete
    self.socialLinksModel.delete
    self.socialLinksModelVariant.delete
    self.temporarySocialLinksModel.delete
    self.temporarySocialLinksModelVariant.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.socialLinksModel = newSocialLinksModel()
    result.socialLinksModelVariant = newQVariant(result.socialLinksModel)
    result.temporarySocialLinksModel = newSocialLinksModel()
    result.temporarySocialLinksModelVariant = newQVariant(result.temporarySocialLinksModel)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc upload*(self: View, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string {.slot.} =
    # var image = singletonInstance.utils.formatImagePath(imageUrl)
    # FIXME the function to get the file size is messed up
    # var size = image_getFileSize(image)
    # TODO find a way to i18n this (maybe send just a code and then QML sets the right string)
    # return "Max file size is 20MB"

    self.delegate.storeIdentityImage(imageUrl, aX, aY, bX, bY)

  proc remove*(self: View): string {.slot.} =
    self.delegate.deleteIdentityImage()

  proc setDisplayName(self: View, displayName: string) {.slot.} =
    self.delegate.setDisplayName(displayName)

  proc socialLinksModel*(self: View): SocialLinksModel =
    return self.socialLinksModel

  proc getSocialLinksModel(self: View): QVariant {.slot.} =
    return self.socialLinksModelVariant

  QtProperty[QVariant] socialLinksModel:
    read = getSocialLinksModel

  proc temporarySocialLinksModel*(self: View): SocialLinksModel =
    return self.temporarySocialLinksModel

  proc getTemporarySocialLinksModel(self: View): QVariant {.slot.} =
    return self.temporarySocialLinksModelVariant

  QtProperty[QVariant] temporarySocialLinksModel:
    read = getTemporarySocialLinksModel

  proc socialLinksDirtyChanged*(self: View) {.signal.}
  proc areSocialLinksDirty(self: View): bool {.slot.} =
    self.socialLinksModel.items != self.temporarySocialLinksModel.items

  proc socialLinksJsonChanged*(self: View) {.signal.}
  proc getSocialLinksJson(self: View): string {.slot.} =
    $(%*self.socialLinksModel.items)

  proc temporarySocialLinksJsonChanged*(self: View) {.signal.}
  proc getTemporarySocialLinksJson(self: View): string {.slot.} =
    $(%*self.temporarySocialLinksModel.items)


  QtProperty[string] socialLinksJson:
    read = getSocialLinksJson
    notify = socialLinksJsonChanged

  QtProperty[string] temporarySocialLinksJson:
    read = getTemporarySocialLinksJson
    notify = temporarySocialLinksJsonChanged

  QtProperty[bool] socialLinksDirty:
    read = areSocialLinksDirty
    notify = socialLinksDirtyChanged

  proc containsSocialLink*(self: View, text: string, url: string): bool {.slot.} =
    return self.temporarySocialLinksModel.containsSocialLink(text, url)

  proc createLink(self: View, text: string, url: string, linkType: int, icon: string) {.slot.} =
    self.temporarySocialLinksModel.appendItem(initSocialLinkItem(text, url, (LinkType)linkType, icon))
    self.temporarySocialLinksJsonChanged()
    self.socialLinksDirtyChanged()

  proc removeLink(self: View, uuid: string) {.slot.} =
    if (self.temporarySocialLinksModel.removeItem(uuid)):
      self.temporarySocialLinksJsonChanged()
      self.socialLinksDirtyChanged()

  proc updateLink(self: View, uuid: string, text: string, url: string) {.slot.} =
    if (self.temporarySocialLinksModel.updateItem(uuid, text, url)):
      self.temporarySocialLinksJsonChanged()
      self.socialLinksDirtyChanged()

  proc moveLink(self: View, fromRow: int, toRow: int) {.slot.} =
    discard self.temporarySocialLinksModel.moveItem(fromRow, toRow)

  proc resetSocialLinks(self: View) {.slot.} =
    if (self.areSocialLinksDirty()):
      self.temporarySocialLinksModel.setItems(self.socialLinksModel.items)
      self.socialLinksDirtyChanged()
      self.temporarySocialLinksJsonChanged()

  proc socialLinksSaved*(self: View, items: seq[SocialLinkItem]) =
    self.socialLinksModel.setItems(items)
    self.temporarySocialLinksModel.setItems(items)
    self.socialLinksJsonChanged()
    self.temporarySocialLinksJsonChanged()

  proc saveSocialLinks(self: View, silent: bool = false) {.slot.} =
    self.delegate.saveSocialLinks()
    if not silent:
      self.socialLinksDirtyChanged()

  proc bioChanged*(self: View) {.signal.}
  proc getBio(self: View): string {.slot.} =
    self.delegate.getBio()
  QtProperty[string] bio:
    read = getBio
    notify = bioChanged

  proc setBio(self: View, bio: string) {.slot.} =
    self.delegate.setBio(bio)

  proc emitBioChangedSignal*(self: View) =
    self.bioChanged()

