import NimQml

import app_service/common/social_links
import app_service/service/profile/dto/profile_showcase
import app_service/service/profile/dto/profile_showcase_preferences
import app_service/service/community/dto/community

import models/profile_preferences_community_item
import models/profile_preferences_account_item
import models/profile_preferences_collectible_item
import models/profile_preferences_asset_item

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

method storeIdentityImage*(self: AccessInterface, imageUrl: string, aX: int, aY: int, bX: int, bY: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteIdentityImage*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getBio*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setBio*(self: AccessInterface, bio: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onBioChanged*(self: AccessInterface, bio: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setDisplayName*(self: AccessInterface, displayName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method saveSocialLinks*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSocialLinksUpdated*(self: AccessInterface, socialLinks: SocialLinks, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method storeProfileShowcasePreferences*(self: AccessInterface,
                                        communities: seq[ProfileShowcaseCommunityItem],
                                        accounts: seq[ProfileShowcaseAccountItem],
                                        collectibles: seq[ProfileShowcaseCollectibleItem],
                                        assets: seq[ProfileShowcaseAssetItem]) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestProfileShowcasePreferences*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestProfileShowcase*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateProfileShowcase*(self: AccessInterface, profileShowcase: ProfileShowcaseDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateProfileShowcasePreferences*(self: AccessInterface, preferences: ProfileShowcasePreferencesDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onContactDetailsUpdated*(self: AccessInterface, contactId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunitiesUpdated*(self: AccessInterface, communities: seq[CommunityDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
