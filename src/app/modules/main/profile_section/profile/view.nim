import NimQml, json, sequtils, sugar, std/algorithm

import io_interface
import app/modules/shared_models/social_links_model
import app/modules/shared_models/social_link_item

# TODO remove old models
import models/profile_preferences_communities_model
import models/profile_preferences_community_item
import models/profile_preferences_accounts_model
import models/profile_preferences_account_item
import models/profile_preferences_collectibles_model
import models/profile_preferences_collectible_item
import models/profile_preferences_assets_model
import models/profile_preferences_asset_item

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
      profileShowcaseCommunitiesModel: ProfileShowcaseCommunitiesModel
      profileShowcaseCommunitiesModelVariant: QVariant
      profileShowcaseAccountsModel: ProfileShowcaseAccountsModel
      profileShowcaseAccountsModelVariant: QVariant
      profileShowcaseCollectiblesModel: ProfileShowcaseCollectiblesModel
      profileShowcaseCollectiblesModelVariant: QVariant
      profileShowcaseAssetsModel: ProfileShowcaseAssetsModel
      profileShowcaseAssetsModelVariant: QVariant

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
    self.QObject.delete
    # TODO: remove old models
    self.socialLinksModel.delete
    self.socialLinksModelVariant.delete
    self.temporarySocialLinksModel.delete
    self.temporarySocialLinksModelVariant.delete
    self.profileShowcaseCommunitiesModel.delete
    self.profileShowcaseCommunitiesModelVariant.delete
    self.profileShowcaseAccountsModel.delete
    self.profileShowcaseAccountsModelVariant.delete
    self.profileShowcaseCollectiblesModel.delete
    self.profileShowcaseCollectiblesModelVariant.delete
    self.profileShowcaseAssetsModel.delete
    self.profileShowcaseAssetsModelVariant.delete

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

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    # TODO: remove old models
    result.socialLinksModel = newSocialLinksModel()
    result.socialLinksModelVariant = newQVariant(result.socialLinksModel)
    result.temporarySocialLinksModel = newSocialLinksModel()
    result.temporarySocialLinksModelVariant = newQVariant(result.temporarySocialLinksModel)
    result.profileShowcaseCommunitiesModel = newProfileShowcaseCommunitiesModel()
    result.profileShowcaseCommunitiesModelVariant = newQVariant(result.profileShowcaseCommunitiesModel)
    result.profileShowcaseAccountsModel = newProfileShowcaseAccountsModel()
    result.profileShowcaseAccountsModelVariant = newQVariant(result.profileShowcaseAccountsModel)
    result.profileShowcaseCollectiblesModel = newProfileShowcaseCollectiblesModel()
    result.profileShowcaseCollectiblesModelVariant = newQVariant(result.profileShowcaseCollectiblesModel)
    result.profileShowcaseAssetsModel = newProfileShowcaseAssetsModel()
    result.profileShowcaseAssetsModelVariant = newQVariant(result.profileShowcaseAssetsModel)

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

  # TODO: remove old models
  proc getCollectiblesModel(self: View): QVariant {.slot.} =
    return self.delegate.getCollectiblesModel()

  QtProperty[QVariant] collectiblesModel:
    read = getCollectiblesModel

  proc getProfileShowcaseCommunitiesModel(self: View): QVariant {.slot.} =
    return self.profileShowcaseCommunitiesModelVariant

  QtProperty[QVariant] profileShowcaseCommunitiesModel:
    read = getProfileShowcaseCommunitiesModel

  proc getProfileShowcaseAccountsModel(self: View): QVariant {.slot.} =
    return self.profileShowcaseAccountsModelVariant

  QtProperty[QVariant] profileShowcaseAccountsModel:
    read = getProfileShowcaseAccountsModel

  proc getProfileShowcaseCollectiblesModel(self: View): QVariant {.slot.} =
    return self.profileShowcaseCollectiblesModelVariant

  QtProperty[QVariant] profileShowcaseCollectiblesModel:
    read = getProfileShowcaseCollectiblesModel

  proc getProfileShowcaseAssetsModel(self: View): QVariant {.slot.} =
    return self.profileShowcaseAssetsModelVariant

  QtProperty[QVariant] profileShowcaseAssetsModel:
    read = getProfileShowcaseAssetsModel

  proc getProfileShowcasePreferencesCommunitiesModel(self: View): QVariant {.slot.} =
    return self.showcasePreferencesCommunitiesModelVariant

  QtProperty[QVariant] showcasePreferencesCommunitiesModel:
    read = getProfileShowcasePreferencesCommunitiesModel

  proc getProfileShowcasePreferencesAccountsModel(self: View): QVariant {.slot.} =
    return self.showcasePreferencesAccountsModelVariant

  QtProperty[QVariant] showcasePreferencesAccountsModel:
    read = getProfileShowcasePreferencesAccountsModel

  proc getProfileShowcasePreferencesCollectiblesModel(self: View): QVariant {.slot.} =
    return self.showcasePreferencesCollectiblesModelVariant

  QtProperty[QVariant] showcasePreferencesCollectiblesModel:
    read = getProfileShowcasePreferencesCollectiblesModel

  proc getProfileShowcasePreferencesAssetsModel(self: View): QVariant {.slot.} =
    return self.showcasePreferencesAssetsModelVariant

  QtProperty[QVariant] showcasePreferencesAssetsModel:
    read = getProfileShowcasePreferencesAssetsModel

  proc getProfileShowcasePreferencesSocialLinksModel(self: View): QVariant {.slot.} =
    return self.showcasePreferencesSocialLinksModelVariant

  QtProperty[QVariant] showcasePreferencesSocialLinksModel:
    read = getProfileShowcasePreferencesSocialLinksModel

  proc clearModels*(self: View) {.slot.} =
    self.profileShowcaseCommunitiesModel.clear()
    self.profileShowcaseAccountsModel.clear()
    self.profileShowcaseCollectiblesModel.clear()
    self.profileShowcaseAssetsModel.clear()

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

  proc requestProfileShowcase(self: View, publicKey: string) {.slot.} =
    self.delegate.requestProfileShowcase(publicKey)

  proc requestProfileShowcasePreferences(self: View) {.slot.} =
    self.delegate.requestProfileShowcasePreferences()

  proc setIsFirstShowcaseInteraction(self: View) {.slot.} =
    self.delegate.setIsFirstShowcaseInteraction()

  proc getProfileShowcaseCommunities*(self: View): seq[ProfileShowcaseCommunityItem] =
    return self.profileShowcaseCommunitiesModel.items()

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

  # TODO: remove setters for old models
  proc updateProfileShowcaseCommunities*(self: View, communities: seq[ProfileShowcaseCommunityItem]) =
    self.profileShowcaseCommunitiesModel.reset(communities.sorted((a, b) => cmp(a.order, b.order), SortOrder.Ascending))

  proc updateProfileShowcaseAccounts*(self: View, accounts: seq[ProfileShowcaseAccountItem]) =
    self.profileShowcaseAccountsModel.reset(accounts.sorted((a, b) => cmp(a.order, b.order), SortOrder.Ascending))

  proc updateProfileShowcaseCollectibles*(self: View, collectibles: seq[ProfileShowcaseCollectibleItem]) =
    self.profileShowcaseCollectiblesModel.reset(collectibles.sorted((a, b) => cmp(a.order, b.order), SortOrder.Ascending))

  proc updateProfileShowcaseAssets*(self: View, assets: seq[ProfileShowcaseAssetItem]) =
    self.profileShowcaseAssetsModel.reset(assets.sorted((a, b) => cmp(a.order, b.order), SortOrder.Ascending))

  proc fetchProfileShowcaseAccountsByAddress*(self: View, address: string) {.slot.} =
    self.delegate.fetchProfileShowcaseAccountsByAddress(address)

  proc profileShowcaseAccountsByAddressFetched*(self: View, accounts: string) {.signal.}
  proc emitProfileShowcaseAccountsByAddressFetchedSignal*(self: View, accounts: string) =
    self.profileShowcaseAccountsByAddressFetched(accounts)
