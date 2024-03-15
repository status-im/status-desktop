import NimQml, json, sequtils

import io_interface
import app/modules/shared_models/social_links_model
import app/modules/shared_models/social_link_item

import models/profile_save_data
import models/showcase_preferences_generic_model
import models/showcase_preferences_social_links_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      # TODO: remove old models
      socialLinksModel: SocialLinksModel
      socialLinksModelVariant: QVariant
      temporarySocialLinksModel: SocialLinksModel # used for editing purposes
      temporarySocialLinksModelVariant: QVariant

      showcasePreferencesCommunitiesModel: ShowcasePreferencesGenericModel
      showcasePreferencesCommunitiesModelVariant: QVariant
      showcasePreferencesAccountsModel: ShowcasePreferencesGenericModel
      showcasePreferencesAccountsModelVariant: QVariant
      showcasePreferencesCollectiblesModel: ShowcasePreferencesGenericModel
      showcasePreferencesCollectiblesModelVariant: QVariant
      showcasePreferencesAssetsModel: ShowcasePreferencesGenericModel
      showcasePreferencesAssetsModelVariant: QVariant
      showcasePreferencesSocialLinksModel: ShowcasePreferencesSocialLinkModel
      showcasePreferencesSocialLinksModelVariant: QVariant

  proc delete*(self: View) =
    # TODO: remove old models
    self.socialLinksModel.delete
    self.socialLinksModelVariant.delete
    self.temporarySocialLinksModel.delete
    self.temporarySocialLinksModelVariant.delete

    self.showcasePreferencesCommunitiesModel.delete
    self.showcasePreferencesCommunitiesModelVariant.delete
    self.showcasePreferencesAccountsModel.delete
    self.showcasePreferencesAccountsModelVariant.delete
    self.showcasePreferencesCollectiblesModel.delete
    self.showcasePreferencesCollectiblesModelVariant.delete
    self.showcasePreferencesAssetsModel.delete
    self.showcasePreferencesAssetsModelVariant.delete
    self.showcasePreferencesSocialLinksModel.delete
    self.showcasePreferencesSocialLinksModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    # TODO: remove old models
    result.socialLinksModel = newSocialLinksModel()
    result.socialLinksModelVariant = newQVariant(result.socialLinksModel)
    result.temporarySocialLinksModel = newSocialLinksModel()
    result.temporarySocialLinksModelVariant = newQVariant(result.temporarySocialLinksModel)

    result.showcasePreferencesCommunitiesModel = newShowcasePreferencesGenericModel()
    result.showcasePreferencesCommunitiesModelVariant = newQVariant(result.showcasePreferencesCommunitiesModel)
    result.showcasePreferencesAccountsModel = newShowcasePreferencesGenericModel()
    result.showcasePreferencesAccountsModelVariant = newQVariant(result.showcasePreferencesAccountsModel)
    result.showcasePreferencesCollectiblesModel = newShowcasePreferencesGenericModel()
    result.showcasePreferencesCollectiblesModelVariant = newQVariant(result.showcasePreferencesCollectiblesModel)
    result.showcasePreferencesAssetsModel = newShowcasePreferencesGenericModel()
    result.showcasePreferencesAssetsModelVariant = newQVariant(result.showcasePreferencesAssetsModel)
    result.showcasePreferencesSocialLinksModel = newShowcasePreferencesSocialLinkModel()
    result.showcasePreferencesSocialLinksModelVariant = newQVariant(result.showcasePreferencesSocialLinksModel)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

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

  proc emitBioChangedSignal*(self: View) =
    self.bioChanged()

  proc profileIdentitySaveSucceeded*(self: View) {.signal.}
  proc emitProfileIdentitySaveSucceededSignal*(self: View) =
    self.profileIdentitySaveSucceeded()

  proc profileIdentitySaveFailed*(self: View) {.signal.}
  proc emitProfileIdentitySaveFailedSignal*(self: View) =
    self.profileIdentitySaveFailed()

  proc profileShowcasePreferencesSaveSucceeded*(self: View) {.signal.}
  proc emitProfileShowcasePreferencesSaveSucceededSignal*(self: View) =
    self.profileShowcasePreferencesSaveSucceeded()

  proc profileShowcasePreferencesSaveFailed*(self: View) {.signal.}
  proc emitProfileShowcasePreferencesSaveFailedSignal*(self: View) =
    self.profileShowcasePreferencesSaveFailed()

  proc getShowcasePreferencesCommunitiesModel(self: View): QVariant {.slot.} =
    return self.showcasePreferencesCommunitiesModelVariant
  QtProperty[QVariant] showcasePreferencesCommunitiesModel:
    read = getShowcasePreferencesCommunitiesModel

  proc getShowcasePreferencesAccountsModel(self: View): QVariant {.slot.} =
    return self.showcasePreferencesAccountsModelVariant
  QtProperty[QVariant] showcasePreferencesAccountsModel:
    read = getShowcasePreferencesAccountsModel

  proc getShowcasePreferencesCollectiblesModel(self: View): QVariant {.slot.} =
    return self.showcasePreferencesCollectiblesModelVariant
  QtProperty[QVariant] showcasePreferencesCollectiblesModel:
    read = getShowcasePreferencesCollectiblesModel

  proc getShowcasePreferencesAssetsModel(self: View): QVariant {.slot.} =
    return self.showcasePreferencesAssetsModelVariant
  QtProperty[QVariant] showcasePreferencesAssetsModel:
    read = getShowcasePreferencesAssetsModel

  proc getShowcasePreferencesSocialLinksModel(self: View): QVariant {.slot.} =
    return self.showcasePreferencesSocialLinksModelVariant
  QtProperty[QVariant] showcasePreferencesSocialLinksModel:
    read = getShowcasePreferencesSocialLinksModel

  proc saveProfileIdentity(self: View, profileData: string) {.slot.} =
    let profileDataObj = profileData.parseJson
    let identityInfo = profileDataObj.toIdentitySaveData()
    self.delegate.saveProfileIdentity(identityInfo)

  proc saveProfileShowcasePreferences(self: View, profileData: string) {.slot.} =
    let profileDataObj = profileData.parseJson
    let showcase = profileDataObj.toShowcaseSaveData()
    self.delegate.saveProfileShowcasePreferences(showcase)

  proc getProfileShowcaseSocialLinksLimit*(self: View): int {.slot.} =
    self.delegate.getProfileShowcaseSocialLinksLimit()

  proc getProfileShowcaseEntriesLimit*(self: View): int {.slot.} =
    self.delegate.getProfileShowcaseEntriesLimit()

  proc requestProfileShowcasePreferences(self: View) {.slot.} =
    self.delegate.requestProfileShowcasePreferences()

  proc setIsFirstShowcaseInteraction(self: View) {.slot.} =
    self.delegate.setIsFirstShowcaseInteraction()

  proc updateProfileShowcasePreferencesCommunities*(self: View, items: seq[ShowcasePreferencesGenericItem]) =
    self.showcasePreferencesCommunitiesModel.setItems(items)

  proc updateProfileShowcasePreferencesAccounts*(self: View, items: seq[ShowcasePreferencesGenericItem]) =
    self.showcasePreferencesAccountsModel.setItems(items)

  proc updateProfileShowcasePreferencesCollectibles*(self: View, items: seq[ShowcasePreferencesGenericItem]) =
    self.showcasePreferencesCollectiblesModel.setItems(items)

  proc updateProfileShowcasePreferencesAssets*(self: View, items: seq[ShowcasePreferencesGenericItem]) =
    self.showcasePreferencesAssetsModel.setItems(items)

  proc updateProfileShowcasePreferencesSocialLinks*(self: View, items: seq[ShowcasePreferencesSocialLinkItem]) =
    self.showcasePreferencesSocialLinksModel.setItems(items)
