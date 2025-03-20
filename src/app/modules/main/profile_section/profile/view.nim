import NimQml, json, sequtils

import io_interface

import models/profile_save_data
import models/showcase_preferences_generic_model
import models/showcase_preferences_social_links_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
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

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
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

  proc saveProfileIdentityChanges(self: View, profileDataChanges: string) {.slot.} =
    let profileDataChangesObj = profileDataChanges.parseJson
    let identityChangesInfo = profileDataChangesObj.toIdentityChangesSaveData()
    self.delegate.saveProfileIdentityChanges(identityChangesInfo)

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

  proc loadProfileShowcasePreferencesCommunities*(self: View, items: seq[ShowcasePreferencesGenericItem]) =
    self.showcasePreferencesCommunitiesModel.setItems(items)

  proc loadProfileShowcasePreferencesAccounts*(self: View, items: seq[ShowcasePreferencesGenericItem]) =
    self.showcasePreferencesAccountsModel.setItems(items)

  proc loadProfileShowcasePreferencesCollectibles*(self: View, items: seq[ShowcasePreferencesGenericItem]) =
    self.showcasePreferencesCollectiblesModel.setItems(items)

  proc loadProfileShowcasePreferencesAssets*(self: View, items: seq[ShowcasePreferencesGenericItem]) =
    self.showcasePreferencesAssetsModel.setItems(items)

  proc loadProfileShowcasePreferencesSocialLinks*(self: View, items: seq[ShowcasePreferencesSocialLinkItem]) =
    self.showcasePreferencesSocialLinksModel.setItems(items)
