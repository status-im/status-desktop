import json, sugar, sequtils, tables

import io_interface

import app/core/eventemitter
import app_service/service/profile/service as profile_service
import app_service/service/settings/service as settings_service
import app_service/service/community/service as community_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/token/service as token_service
import app_service/common/social_links

import app_service/service/profile/dto/profile_showcase_entry
import models/profile_preferences_community_item
import models/profile_preferences_account_item
import models/profile_preferences_collectible_item
import models/profile_preferences_asset_item

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    profileService: profile_service.Service
    settingsService: settings_service.Service
    communityService: community_service.Service
    walletAccountService: wallet_account_service.Service
    tokenService: token_service.Service

  # Forward declaration
proc updateShowcasePreferences(self: Controller, communities, accounts, collectibles, assets: Table[string, ProfileShowcaseEntryDto])

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    profileService: profile_service.Service,
    settingsService: settings_service.Service,
    communityService: community_service.Service,
    walletAccountService: wallet_account_service.Service,
    tokenService: token_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.profileService = profileService
  result.settingsService = settingsService
  result.communityService = communityService
  result.walletAccountService = walletAccountService
  result.tokenService = tokenService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.settingsService.fetchAndStoreSocialLinks()

  self.events.on(SIGNAL_BIO_UPDATED) do(e: Args):
    let args = SettingsTextValueArgs(e)
    self.delegate.onBioChanged(args.value)

  self.events.on(SIGNAL_SOCIAL_LINKS_UPDATED) do(e: Args):
    let args = SocialLinksArgs(e)
    self.delegate.onSocialLinksUpdated(args.socialLinks, args.error)

  self.events.on(SIGNAL_PROFILE_SHOWCASE_PREFERENCES_LOADED) do(e: Args):
    let args = ProfileShowcasePreferencesArgs(e)
    self.updateShowcasePreferences(args.communities, args.accounts, args.collectibles, args.assets)

proc updateShowcasePreferences(self: Controller, communities, accounts, collectibles, assets: Table[string, ProfileShowcaseEntryDto]) =
  var profileCommunityItems: seq[ProfileShowcaseCommunityItem] = @[]
  var profileAccountItems: seq[ProfileShowcaseAccountItem] = @[]
  var profileCollectibleItems: seq[ProfileShowcaseCollectibleItem] = @[]
  var profileAssetItems: seq[ProfileShowcaseAssetItem] = @[]

  # Collect all joined & curated communities to fill perferences with defaults only on UI
  # NOTE: Should i also include getCuratedCommunities()?
  for community in self.communityService.getJoinedCommunities():
    var profileEntry: ProfileShowcaseEntryDto
    if communities.contains(community.id):
      profileEntry = communities[community.id]
    else:
      profileEntry = ProfileShowcaseEntryDto(
        id: community.id,
        entryType: ProfileShowcaseEntryType.Community,
        visibility: ProfileShowcaseVisibility.ToNoOne,
        order: 0
      )
    profileCommunityItems.add(initProfileShowcaseCommunityItem(community, profileEntry))

    # TODO: collect community tokens & collectibles 

  # Collect wallet accounts
  for walletAccount in self.walletAccountService.getWalletAccounts():
    var walletProfileEntry: ProfileShowcaseEntryDto
    if accounts.contains(walletAccount.address):
      walletProfileEntry = accounts[walletAccount.address]
    else:
      walletProfileEntry = ProfileShowcaseEntryDto(
        id: walletAccount.address,
        entryType: ProfileShowcaseEntryType.Account,
        visibility: ProfileShowcaseVisibility.ToNoOne,
        order: 0
      )
    profileAccountItems.add(initProfileShowcaseAccountItem(walletAccount, walletProfileEntry))

    # Collect tokens for each wallet address
    for token in self.walletAccountService.getTokensByAddress(walletAccount.address):
      var tokenProfileEntry: ProfileShowcaseEntryDto
      if accounts.contains(token.symbol):
        tokenProfileEntry = accounts[token.symbol]
      else:
        tokenProfileEntry = ProfileShowcaseEntryDto(
          id: token.symbol,
          entryType: ProfileShowcaseEntryType.Account,
          visibility: ProfileShowcaseVisibility.ToNoOne,
          order: 0
        )
      profileAssetItems.add(initProfileShowcaseAssetItem(token, tokenProfileEntry))

    # TODO collect collectibles
    # Community collectibles (ERC721 and others)
    #   profileCollectibleItems.add(initProfileShowcaseCollectibleItem(token, profileEntry))

    self.delegate.setProfileShowcaseCommunitiesPreferences(profileCommunityItems)
    self.delegate.setProfileShowcaseAccountsPreferences(profileAccountItems)
    self.delegate.setProfileShowcaseCollectiblesPreferences(profileCollectibleItems)
    self.delegate.setProfileShowcaseAssetsPreferences(profileAssetItems)

proc storeIdentityImage*(self: Controller, address: string, image: string, aX: int, aY: int, bX: int, bY: int) =
  discard self.profileService.storeIdentityImage(address, image, aX, aY, bX, bY)

proc deleteIdentityImage*(self: Controller, address: string) =
  self.profileService.deleteIdentityImage(address)

proc setDisplayName*(self: Controller, displayName: string) =
  self.profileService.setDisplayName(displayName)

proc getSocialLinks*(self: Controller): SocialLinks =
  return self.settingsService.getSocialLinks()

proc setSocialLinks*(self: Controller, links: SocialLinks) =
  self.settingsService.setSocialLinks(links)

proc getBio*(self: Controller): string =
  self.settingsService.getBio()

proc setBio*(self: Controller, bio: string): bool =
  self.settingsService.saveBio(bio)

proc storeProfileShowcasePreferences*(self: Controller, profileChanges: string) =
  echo "--------------> storeProfileShowcasePreferences: ", profileChanges
  # TODO: storeProfileShowcasePreferences in service

proc requestProfileShowcasePreferences*(self: Controller) =
  self.profileService.requestProfileShowcasePreferences()
