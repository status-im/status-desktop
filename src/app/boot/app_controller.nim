import NimQml, os, strformat

import ../../app_service/service/local_settings/service as local_settings_service
import ../../app_service/service/keychain/service as keychain_service
import ../../app_service/service/accounts/service as accounts_service
import ../../app_service/service/contacts/service as contact_service
import ../../app_service/service/chat/service as chat_service
import ../../app_service/service/community/service as community_service
import ../core/local_account_settings
import ../modules/startup/module as startup_module
import ../modules/main/module as main_module

import ../core/global_singleton

# This will be removed later once we move to c++ and handle there async things
# and improved some services, like EventsService which should implement 
# provider/subscriber principe:
import ../../app_service/[main]
import eventemitter
import status/[fleet]

#################################################
# At the end of refactoring this will be moved to 
# appropriate place or removed:
import ../profile/core as profile
# import ../onboarding/core as onboarding
# import ../login/core as login
import status/types/[account]
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

var currentLanguageCode: string
proc changeLanguage(locale: string) =
  if (locale == currentLanguageCode):
    return
  currentLanguageCode = locale
  let shouldRetranslate = not defined(linux)
  singletonInstance.engine.setTranslationPackage(
    joinPath(i18nPath, fmt"qml_{locale}.qm"), shouldRetranslate)

type 
  AppController* = ref object of RootObj 
    appService: AppService
    # Services
    localSettingsService: local_settings_service.Service
    keychainService: keychain_service.Service
    accountsService: accounts_service.Service
    contactService: contact_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    # Core
    localAccountSettings: LocalAccountSettings
    localAccountSettingsVariant: QVariant
    # Modules
    startupModule: startup_module.AccessInterface
    mainModule: main_module.AccessInterface

    #################################################
    # At the end of refactoring this will be moved to 
    # appropriate place or removed:
    profile: ProfileController
    # login: LoginController
    # onboarding: OnboardingController
    # accountArgs: AccountArgs
    #################################################

#################################################
# Forward declaration section
proc load*(self: AppController)

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

# self.appService.status.events.once("login") do(a: Args):
#   self.accountArgs = AccountArgs(a)
#   self.load()

# self.appService.status.events.once("nodeStopped") do(a: Args):
#   self.login.reset()
#   self.onboarding.reset()
#################################################

proc newAppController*(appService: AppService): AppController =
  result = AppController()
  result.appService = appService
  # Services
  result.localSettingsService = local_settings_service.newService()
  result.keychainService = keychain_service.newService(result.localSettingsService, 
  appService.status.events)
  result.accountsService = accounts_service.newService()
  result.contactService = contact_service.newService()
  result.chatService = chat_service.newService()
  result.communityService = community_service.newService(result.chatService)
  # Core
  result.localAccountSettings = newLocalAccountSettings(result.localSettingsService)
  result.localAccountSettingsVariant = newQVariant(result.localAccountSettings)
  # Modules
  result.startupModule = startup_module.newModule[AppController](result,
  appService.status.events, appService.status.fleet, result.localSettingsService,
  result.keychainService, result.accountsService)
  result.mainModule = main_module.newModule[AppController](result, 
  appService.status.events, result.localSettingsService, result.keychainService, 
  result.accountsService, result.chatService, result.communityService)

  #################################################
  # At the end of refactoring this will be moved to 
  # appropriate place or removed:
  result.profile = profile.newController(appService.status, appService, 
  result.localSettingsService, changeLanguage)
  # result.login = login.newController(appService.status, appService)
  # result.onboarding = onboarding.newController(appService.status)
  # singletonInstance.engine.setRootContextProperty("loginModel", result.login.variant)
  # singletonInstance.engine.setRootContextProperty("onboardingModel", result.onboarding.variant)
  result.connect()
  #################################################

proc delete*(self: AppController) =
  self.startupModule.delete
  self.mainModule.delete
  
  #################################################
  # At the end of refactoring this will be moved to 
  # appropriate place or removed:
  # self.login.delete
  # self.onboarding.delete
  self.profile.delete
  #################################################

  self.localSettingsService.delete
  self.localAccountSettingsVariant.delete

  self.localSettingsService.delete
  self.accountsService.delete
  self.contactService.delete
  self.chatService.delete
  self.communityService.delete

proc startupDidLoad*(self: AppController) =
  #################################################
  # At the end of refactoring this will be moved to 
  # appropriate place or removed:
  singletonInstance.engine.setRootContextProperty("profileModel", self.profile.variant)
  # self.login.init()
  # self.onboarding.init()
  #################################################

  # We're applying default language before we load qml. Also we're aware that
  # switch language at runtime will have some impact to cpu usage.
  # https://doc.qt.io/archives/qtjambi-4.5.2_01/com/trolltech/qt/qtjambi-linguist-programmers.html
  changeLanguage("en")

  singletonInstance.engine.setRootContextProperty("localAccountSettings", 
  self.localAccountSettingsVariant)
  singletonInstance.engine.load(newQUrl("qrc:///main.qml"))

  #self.startupModule.offerToLoginUsingKeychain()

proc mainDidLoad*(self: AppController) =
  self.appService.onLoggedIn()
  self.startupModule.moveToAppState()

  self.mainModule.checkForStoringPassword()

  #################################################
  # At the end of refactoring this will be moved to 
  # appropriate place or removed:
  # Reset login and onboarding to remove any mnemonic that would have been saved in the accounts list
  # self.login.reset()
  # self.onboarding.reset()

  # self.login.moveToAppState()
  # self.onboarding.moveToAppState()
  # self.appService.status.events.emit("loginCompleted", self.accountArgs)
  #################################################

proc start*(self: AppController) =
  self.accountsService.init()
  
  self.startupModule.load()

proc load*(self: AppController) =
  self.contactService.init()
  self.chatService.init()
  self.communityService.init()
  
  self.mainModule.load()

proc userLoggedIn*(self: AppController) =
  self.load()