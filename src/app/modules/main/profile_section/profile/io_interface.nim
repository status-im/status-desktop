import nimqml

import app_service/service/profile/dto/profile_showcase_preferences

import models/profile_save_data

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getBio*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setBio*(self: AccessInterface, bio: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onBioChanged*(self: AccessInterface, bio: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setDisplayName*(self: AccessInterface, displayName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onProfileShowcasePreferencesSaveSucceeded*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onProfileShowcasePreferencesSaveFailed*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method saveProfileIdentityChanges*(self: AccessInterface, identity: IdentityChangesSaveData) {.base.} =
  raise newException(ValueError, "No implementation available")

method saveProfileShowcasePreferences*(self: AccessInterface, showcase: ShowcaseSaveData) {.base.} =
  raise newException(ValueError, "No implementation available")

method getProfileShowcaseSocialLinksLimit*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getProfileShowcaseEntriesLimit*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method requestProfileShowcasePreferences*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setIsFirstShowcaseInteraction*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadProfileShowcasePreferences*(self: AccessInterface, preferences: ProfileShowcasePreferencesDto) {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
