import NimQml, os, strformat

import ../../app_service/service/keychain/service as keychain_service
import ../../app_service/service/accounts/service as accounts_service
import ../../app_service/service/contacts/service as contacts_service
import ../../app_service/service/language/service as language_service
import ../../app_service/service/chat/service as chat_service
import ../../app_service/service/community/service as community_service
import ../../app_service/service/token/service as token_service
import ../../app_service/service/transaction/service as transaction_service
import ../../app_service/service/collectible/service as collectible_service
import ../../app_service/service/wallet_account/service as wallet_account_service
import ../../app_service/service/setting/service as setting_service
import ../../app_service/service/bookmarks/service as bookmark_service
import ../../app_service/service/dapp_permissions/service as dapp_permissions_service
import ../../app_service/service/mnemonic/service as mnemonic_service
import ../../app_service/service/privacy/service as privacy_service
import ../../app_service/service/provider/service as provider_service
import ../../app_service/service/ens/service as ens_service
import ../../app_service/service/appearance/service as appearance_service
import ../../app_service/service/syncnode/service as syncnode_service
import ../../app_service/service/devicesync/service as devicesync_service
import ../../app_service/service/network/service as network_service

import ../core/local_account_settings
import ../../app_service/service/profile/service as profile_service
import ../../app_service/service/settings/service as settings_service
import ../../app_service/service/about/service as about_service
import ../modules/startup/module as startup_module
import ../modules/main/module as main_module

import ../core/global_singleton

#################################################
# This will be removed later once we move to c++ and handle there async things
# and improved some services, like EventsService which should implement 
# provider/subscriber principe, similar we should have SettingsService.
import ../../app_service/[main]
import eventemitter
import status/[fleet]
import ../profile/core as profile
import status/types/[account, setting]
#################################################

var i18nPath = ""
if defined(development):
  i18nPath = joinPath(getAppDir(), "../ui/i18n")
elif (defined(windows)):
  i18nPath = joinPath(getAppDir(), "../resources/i18n")
elif (defined(macosx)):
  i18nPath = joinPath(getAppDir(), "../i18n")
elif (defined(linux)):
  i18nPath = joinPath(getAppDir(), "../i18n")

proc setLanguage(locale: string) =
  let shouldRetranslate = not defined(linux)
  singletonInstance.engine.setTranslationPackage(joinPath(i18nPath, fmt"qml_{locale}.qm"), shouldRetranslate)

proc changeLanguage(locale: string) =
  let currentLanguageCode = singletonInstance.localAppSettings.getLocale()
  if (locale == currentLanguageCode):
    return

  singletonInstance.localAppSettings.setLocale(locale)
  setLanguage(locale)

type 
  AppController* = ref object of RootObj 
    appService: AppService
    # Services
    keychainService: keychain_service.Service
    accountsService: accounts_service.Service
    contactsService: contacts_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    tokenService: token_service.Service
    transactionService: transaction_service.Service
    collectibleService: collectible_service.Service
    walletAccountService: wallet_account_service.Service
    settingService: setting_service.Service
    bookmarkService: bookmark_service.Service
    dappPermissionsService: dapp_permissions_service.Service
    ensService: ens_service.Service
    providerService: provider_service.Service
    profileService: profile_service.Service
    settingsService: settings_service.Service
    aboutService: about_service.Service
    languageService: language_service.Service
    mnemonicService: mnemonic_service.Service
    privacyService: privacy_service.Service
    appearanceService: appearance_service.Service
    syncnodeService: syncnode_service.Service
    deviceSyncService: devicesync_service.Service
    networkService: network_service.Service

    # Core
    localAppSettingsVariant: QVariant
    localAccountSettingsVariant: QVariant
    localAccountSensitiveSettingsVariant: QVariant
    userProfileVariant: QVariant

    # Modules
    startupModule: startup_module.AccessInterface
    mainModule: main_module.AccessInterface

    #################################################
    # At the end of refactoring this will be moved to 
    # appropriate place or removed:
    profile: ProfileController
    #################################################

#################################################
# Forward declaration section
proc load(self: AppController)
proc buildAndRegisterLocalAccountSensitiveSettings(self: AppController)
proc buildAndRegisterUserProfile(self: AppController)

# Startup Module Delegate Interface
proc startupDidLoad*(self: AppController)
proc userLoggedIn*(self: AppController)

# Main Module Delegate Interface
proc mainDidLoad*(self: AppController)
#################################################

#################################################
# At the end of refactoring this will be moved to 
# appropriate place or removed:
proc connect(self: AppController) =
  self.appService.status.events.once("loginCompleted") do(a: Args):
    var args = AccountArgs(a)
    self.profile.init(args.account)
#################################################

proc newAppController*(appService: AppService): AppController =
  result = AppController()
  result.appService = appService
  # Services
  result.keychainService = keychain_service.newService(appService.status.events)
  result.settingService = setting_service.newService()
  result.settingsService = settings_service.newService(appService.status.fleet)
  result.accountsService = accounts_service.newService()
  result.contactsService = contacts_service.newService(appService.status.events, appService.threadpool)
  result.chatService = chat_service.newService()
  result.communityService = community_service.newService(result.chatService)
  result.tokenService = token_service.newService(appService.status.events, appService.threadpool, result.settingService, result.settingsService)
  result.collectibleService = collectible_service.newService(result.settingService)
  result.walletAccountService = wallet_account_service.newService(
    appService.status.events, result.settingService, result.tokenService
  )
  result.transactionService = transaction_service.newService(appService.status.events, appService.threadpool, result.walletAccountService)
  result.bookmarkService = bookmark_service.newService()
  result.profileService = profile_service.newService()
  result.aboutService = about_service.newService()
  result.dappPermissionsService = dapp_permissions_service.newService()
  result.languageService = language_service.newService()
  result.mnemonicService = mnemonic_service.newService()
  result.privacyService = privacy_service.newService()
  result.ensService = ens_service.newService()
  result.providerService = provider_service.newService(result.dappPermissionsService, result.settingsService, result.ensService)
  result.appearanceService = appearance_service.newService()
  result.syncnodeService = syncnode_service.newService()
  result.deviceSyncService = devicesync_service.newService()
  result.networkService = network_service.newService()

  # Core
  result.localAppSettingsVariant = newQVariant(singletonInstance.localAppSettings)
  result.localAccountSettingsVariant = newQVariant(singletonInstance.localAccountSettings)
  result.localAccountSensitiveSettingsVariant = newQVariant(singletonInstance.localAccountSensitiveSettings)
  result.userProfileVariant = newQVariant(singletonInstance.userProfile)

  # Modules
  result.startupModule = startup_module.newModule[AppController](
    result,
    appService.status.events,
    appService.status.fleet,
    result.keychainService, 
    result.accountsService
  )
  result.mainModule = main_module.newModule[AppController](
    result, 
    appService.status.events,
    result.keychainService,
    result.accountsService, 
    result.chatService,
    result.communityService,
    result.tokenService,
    result.transactionService,
    result.collectibleService,
    result.walletAccountService,
    result.bookmarkService,
    result.settingService,
    result.profileService,
    result.settingsService,
    result.contactsService,
    result.aboutService,
    result.dappPermissionsService,
    result.languageService,
    result.mnemonicService,
    result.privacyService,
    result.providerService,
    result.appearanceService,
    result.syncnodeService,
    result.deviceSyncService,
    result.networkService
  )

  #################################################
  # At the end of refactoring this will be moved to 
  # appropriate place or removed:
  result.profile = profile.newController(appService.status, appService, changeLanguage)
  result.connect()
  #################################################

  # Adding status and appService here now is just because of having a controll 
  # over order of execution while we integrating this refactoring architecture 
  # into the current app state.
  # Once we complete refactoring process we will get rid of "status" part/lib.
  #
  # This to will be adapted to appropriate modules later:
  # result.login = login.newController(appService.status, appService)
  # result.onboarding = onboarding.newController(appService.status)
  # singletonInstance.engine.setRootContextProperty("loginModel", result.login.variant)
  # singletonInstance.engine.setRootContextProperty("onboardingModel", result.onboarding.variant)
  #result.connect()

proc delete*(self: AppController) =
  self.contactsService.delete
  self.chatService.delete
  self.communityService.delete
  self.bookmarkService.delete
  self.startupModule.delete
  self.mainModule.delete
  
  #################################################
  # At the end of refactoring this will be moved to 
  # appropriate place or removed:
  self.profile.delete
  #################################################

  self.localAppSettingsVariant.delete
  self.localAccountSettingsVariant.delete
  self.localAccountSensitiveSettingsVariant.delete
  self.userProfileVariant.delete

  self.accountsService.delete
  self.chatService.delete
  self.communityService.delete
  self.tokenService.delete
  self.transactionService.delete
  self.collectibleService.delete
  self.settingService.delete
  self.walletAccountService.delete
  self.aboutService.delete
  self.dappPermissionsService.delete
  self.providerService.delete
  self.ensService.delete
  self.syncnodeService.delete
  self.deviceSyncService.delete
  self.networkService.delete

proc startupDidLoad*(self: AppController) =
  #################################################
  # At the end of refactoring this will be moved to 
  # appropriate place or removed:
  singletonInstance.engine.setRootContextProperty("profileModel", self.profile.variant)
  #################################################

  singletonInstance.engine.setRootContextProperty("localAppSettings", self.localAppSettingsVariant)
  singletonInstance.engine.setRootContextProperty("localAccountSettings", self.localAccountSettingsVariant)
  singletonInstance.engine.load(newQUrl("qrc:///main.qml"))

  # We need to set a language once qml is loaded
  let locale = singletonInstance.localAppSettings.getLocale()
  setLanguage(locale)

proc mainDidLoad*(self: AppController) =
  self.appService.onLoggedIn()
  self.startupModule.moveToAppState()

  self.mainModule.checkForStoringPassword()

proc start*(self: AppController) =
  self.accountsService.init()
  
  self.startupModule.load()

proc load(self: AppController) =
  # init services which are available only if a user is logged in
  self.settingService.init()
  self.contactsService.init()
  self.chatService.init()
  self.communityService.init()
  self.bookmarkService.init()
  self.tokenService.init()
  self.settingsService.init()
  self.dappPermissionsService.init()
  self.ensService.init()
  self.providerService.init()
  self.walletAccountService.init()
  self.transactionService.init()
  self.languageService.init()

  # other global instances
  self.buildAndRegisterLocalAccountSensitiveSettings()  
  self.buildAndRegisterUserProfile()

  # load main module
  self.mainModule.load()

proc userLoggedIn*(self: AppController) =
  #################################################
  # At the end of refactoring this will be removed:
  let loggedInUser = self.accountsService.getLoggedInAccount()
  let account = Account(name: loggedInUser.name, keyUid: loggedInUser.keyUid)
  self.appService.status.events.emit("loginCompleted", AccountArgs(account: account))
  #################################################
  self.load()

proc buildAndRegisterLocalAccountSensitiveSettings(self: AppController) = 
  var pubKey = self.settingsService.getPubKey()
  singletonInstance.localAccountSensitiveSettings.setFileName(pubKey)
  singletonInstance.engine.setRootContextProperty("localAccountSensitiveSettings", self.localAccountSensitiveSettingsVariant)

proc buildAndRegisterUserProfile(self: AppController) = 
  let loggedInAccount = self.accountsService.getLoggedInAccount()

  let pubKey = self.settingsService.getPubKey()
  let sendUserStatus = self.settingsService.getSendUserStatus()
  ## This is still not in use. Read a comment in UserProfile.
  ## let currentUserStatus = self.settingsService.getCurrentUserStatus()
  let obj = self.settingsService.getIdentityImage(loggedInAccount.keyUid)

  singletonInstance.userProfile.setFixedData(loggedInAccount.name, loggedInAccount.keyUid, loggedInAccount.identicon, 
  pubKey)
  singletonInstance.userProfile.setEnsName("") # in this moment we don't know ens name
  singletonInstance.userProfile.setThumbnailImage(obj.thumbnail)
  singletonInstance.userProfile.setLargeImage(obj.large)
  singletonInstance.userProfile.setUserStatus(sendUserStatus)

  singletonInstance.engine.setRootContextProperty("userProfile", self.userProfileVariant)
