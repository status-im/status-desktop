import sugar, sequtils
import io_interface

import app/global/app_signals
import app/core/eventemitter
import app_service/service/profile/service as profile_service
import app_service/service/settings/service as settings_service
import app_service/service/community/service as community_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/token/service as token_service
import app_service/common/social_links
import app_service/common/types

import app_service/service/profile/dto/profile_showcase_preferences

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    profileService: profile_service.Service
    settingsService: settings_service.Service
    communityService: community_service.Service
    walletAccountService: wallet_account_service.Service
    networkService: network_service.Service
    tokenService: token_service.Service

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    profileService: profile_service.Service,
    settingsService: settings_service.Service,
    communityService: community_service.Service,
    walletAccountService: wallet_account_service.Service,
    networkService: network_service.Service,
    tokenService: token_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.profileService = profileService
  result.settingsService = settingsService
  result.communityService = communityService
  result.walletAccountService = walletAccountService
  result.networkService = networkService
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

  self.events.on(SIGNAL_PROFILE_SHOWCASE_PREFERENCES_SAVE_SUCCEEDED) do(e: Args):
    self.delegate.onProfileShowcasePreferencesSaveSucceeded()

  self.events.on(SIGNAL_PROFILE_SHOWCASE_PREFERENCES_SAVE_FAILED) do(e: Args):
    self.delegate.onProfileShowcasePreferencesSaveFailed()

  self.events.on(SIGNAL_PROFILE_SHOWCASE_PREFERENCES_UPDATED) do(e: Args):
    let args = ProfileShowcasePreferencesArgs(e)
    self.delegate.updateProfileShowcasePreferences(args.preferences)

  self.events.on(SIGNAL_PROFILE_SHOWCASE_FOR_CONTACT_UPDATED) do(e: Args):
    let args = ProfileShowcaseForContactArgs(e)
    self.delegate.updateProfileShowcase(args.profileShowcase)

  self.events.on(SIGNAL_PROFILE_SHOWCASE_ACCOUNTS_BY_ADDRESS_FETCHED) do(e: Args):
    let args = ProfileShowcaseForContactArgs(e)
    self.delegate.onProfileShowcaseAccountsByAddressFetched(args.profileShowcase.accounts)

  self.events.on(SIGNAL_COMMUNITIES_UPDATE) do(e: Args):
    let args = CommunitiesArgs(e)
    self.delegate.onCommunitiesUpdated(args.communities)

proc storeIdentityImage*(self: Controller, address: string, image: string, aX: int, aY: int, bX: int, bY: int): bool =
  len(self.profileService.storeIdentityImage(address, image, aX, aY, bX, bY)) > 0

proc deleteIdentityImage*(self: Controller, address: string): bool =
  self.profileService.deleteIdentityImage(address)

proc setDisplayName*(self: Controller, displayName: string): bool =
  self.profileService.setDisplayName(displayName)

proc getSocialLinks*(self: Controller): SocialLinks =
  self.settingsService.getSocialLinks()

proc getCommunityById*(self: Controller, id: string): CommunityDto =
  self.communityService.getCommunityById(id)

proc getAccountByAddress*(self: Controller, address: string): WalletAccountDto =
  self.walletAccountService.getAccountByAddress(address)

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  self.walletAccountService.getWalletAccounts(true)

proc getChainIds*(self: Controller): seq[int] =
  self.networkService.getCurrentNetworks().map(n => n.chainId)

proc setSocialLinks*(self: Controller, links: SocialLinks) =
  self.settingsService.setSocialLinks(links)

proc getBio*(self: Controller): string =
  self.settingsService.getBio()

proc setBio*(self: Controller, bio: string): bool =
  self.settingsService.saveBio(bio)

proc storeProfileShowcasePreferences*(self: Controller, preferences: ProfileShowcasePreferencesDto, revealedAddresses: seq[string]) =
  self.profileService.saveProfileShowcasePreferences(preferences)
  self.events.emit(MARK_WALLET_ADDRESSES_AS_SHOWN, WalletAddressesArgs(addresses: revealedAddresses))

proc requestProfileShowcasePreferences*(self: Controller) =
  self.profileService.requestProfileShowcasePreferences()

proc requestProfileShowcaseForContact*(self: Controller, contactId: string) =
  self.profileService.requestProfileShowcaseForContact(contactId)

proc fetchProfileShowcaseAccountsByAddress*(self: Controller, address: string) =
  self.profileService.fetchProfileShowcaseAccountsByAddress(address)

proc getProfileShowcaseSocialLinksLimit*(self: Controller): int =
  self.profileService.getProfileShowcaseSocialLinksLimit()

proc getProfileShowcaseEntriesLimit*(self: Controller): int =
  self.profileService.getProfileShowcaseEntriesLimit()

proc requestCommunityInfo*(self: Controller, communityId: string, shard: Shard) =
  self.communityService.requestCommunityInfo(communityId, shard)

proc getTokenBySymbolList*(self: Controller): var seq[TokenBySymbolItem] =
  self.tokenService.getTokenBySymbolList()
