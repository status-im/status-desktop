import NimQml, json, sequtils, sugar, std/algorithm

import io_interface
import app/modules/shared_models/social_links_model
import app/modules/shared_models/social_link_item

import models/profile_preferences_communities_model
import models/profile_preferences_community_item
import models/profile_preferences_accounts_model
import models/profile_preferences_account_item
import models/profile_preferences_collectibles_model
import models/profile_preferences_collectible_item
import models/profile_preferences_assets_model
import models/profile_preferences_asset_item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
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

  proc delete*(self: View) =
    self.QObject.delete
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

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
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

  proc storeProfileShowcasePreferences(self: View) {.slot.} =
    let communities = self.profileShowcaseCommunitiesModel.items()
    let accounts = self.profileShowcaseAccountsModel.items()
    let collectibles = self.profileShowcaseCollectiblesModel.items()
    let assets = self.profileShowcaseAssetsModel.items()

    self.delegate.storeProfileShowcasePreferences(communities, accounts, collectibles, assets)

  proc clearModels*(self: View) {.slot.} =
    self.profileShowcaseCommunitiesModel.clear()
    self.profileShowcaseAccountsModel.clear()
    self.profileShowcaseCollectiblesModel.clear()
    self.profileShowcaseAssetsModel.clear()

  proc requestProfileShowcase(self: View, publicKey: string) {.slot.} =
    self.delegate.requestProfileShowcase(publicKey)

  proc requestProfileShowcasePreferences(self: View) {.slot.} =
    self.delegate.requestProfileShowcasePreferences()

  proc getProfileShowcaseCommunities*(self: View): seq[ProfileShowcaseCommunityItem] =
    return self.profileShowcaseCommunitiesModel.items()

  proc updateProfileShowcaseCommunities*(self: View, communities: seq[ProfileShowcaseCommunityItem]) =
    self.profileShowcaseCommunitiesModel.reset(communities.sorted((a, b) => cmp(a.order, b.order), SortOrder.Ascending))

  proc updateProfileShowcaseAccounts*(self: View, accounts: seq[ProfileShowcaseAccountItem]) =
    self.profileShowcaseAccountsModel.reset(accounts.sorted((a, b) => cmp(a.order, b.order), SortOrder.Ascending))

  proc updateProfileShowcaseCollectibless*(self: View, collectibles: seq[ProfileShowcaseCollectibleItem]) =
    self.profileShowcaseCollectiblesModel.reset(collectibles.sorted((a, b) => cmp(a.order, b.order), SortOrder.Ascending))

  proc updateProfileShowcaseAssets*(self: View, assets: seq[ProfileShowcaseAssetItem]) =
    self.profileShowcaseAssetsModel.reset(assets.sorted((a, b) => cmp(a.order, b.order), SortOrder.Ascending))
