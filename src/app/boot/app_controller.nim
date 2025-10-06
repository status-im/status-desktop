import nimqml, sequtils, chronicles

import app_service/service/general/service as general_service
import app_service/service/keychain/service as keychain_service
import app_service/service/keycard/service as keycard_service
import app_service/service/keycardV2/service as keycard_serviceV2
import app_service/service/accounts/service as accounts_service
import app_service/service/contacts/service as contacts_service
import app_service/service/language/service as language_service
import app_service/service/chat/service as chat_service
import app_service/service/community/service as community_service
import app_service/service/message/service as message_service
import app_service/service/token/service as token_service
import app_service/service/collectible/service as collectible_service
import app_service/service/currency/service as currency_service
import app_service/service/ramp/service as ramp_service
import app_service/service/transaction/service as transaction_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/bookmarks/service as bookmark_service
import app_service/service/dapp_permissions/service as dapp_permissions_service
import app_service/service/privacy/service as privacy_service
import app_service/service/provider/service as provider_service
import app_service/service/node/service as node_service
import app_service/service/profile/service as profile_service
import app_service/service/settings/service as settings_service
import app_service/service/stickers/service as stickers_service
import app_service/service/about/service as about_service
import app_service/service/node_configuration/service as node_configuration_service
import app_service/service/network/service as network_service
import app_service/service/activity_center/service as activity_center_service
import app_service/service/saved_address/service as saved_address_service
import app_service/service/devices/service as devices_service
import app_service/service/mailservers/service as mailservers_service
import app_service/service/gif/service as gif_service
import app_service/service/ens/service as ens_service
import app_service/service/community_tokens/service as tokens_service
import app_service/service/network_connection/service as network_connection_service
import app_service/service/shared_urls/service as shared_urls_service
import app_service/service/metrics/service as metrics_service
import app_service/service/market/service as market_service

import app/modules/onboarding/module as onboarding_module
import app/modules/onboarding/post_onboarding/[keycard_replacement_task, keycard_convert_account, save_biometrics_task]
import app/modules/main/module as main_module
import app/core/notifications/notifications_manager
import app/global/global_singleton
import app/global/app_signals
import app/core/[main]

import constants as main_constants

logScope:
  topics = "app-controller"

type
  AppController* = ref object of RootObj
    statusFoundation: StatusFoundation
    notificationsManager*: NotificationsManager

    # Global
    appSettingsVariant: QVariant
    localAppSettingsVariant: QVariant
    localAccountSettingsVariant: QVariant
    localAccountSensitiveSettingsVariant: QVariant
    userProfileVariant: QVariant
    globalUtilsVariant: QVariant
    metricsVariant: QVariant

    # Services
    generalService: general_service.Service
    keycardService*: keycard_service.Service
    keycardServiceV2*: keycard_serviceV2.Service
    keychainService: keychain_service.Service
    accountsService: accounts_service.Service
    contactsService: contacts_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service
    tokenService: token_service.Service
    collectibleService: collectible_service.Service
    currencyService: currency_service.Service
    rampService: ramp_service.Service
    transactionService: transaction_service.Service
    walletAccountService: wallet_account_service.Service
    bookmarkService: bookmark_service.Service
    dappPermissionsService: dapp_permissions_service.Service
    providerService: provider_service.Service
    profileService: profile_service.Service
    settingsService: settings_service.Service
    stickersService: stickers_service.Service
    aboutService: about_service.Service
    networkService: network_service.Service
    activityCenterService: activity_center_service.Service
    languageService: language_service.Service
    privacyService: privacy_service.Service
    nodeConfigurationService: node_configuration_service.Service
    savedAddressService: saved_address_service.Service
    devicesService: devices_service.Service
    mailserversService: mailservers_service.Service
    nodeService: node_service.Service
    gifService: gif_service.Service
    ensService: ens_service.Service
    tokensService: tokens_service.Service
    networkConnectionService: network_connection_service.Service
    sharedUrlsService: shared_urls_service.Service
    metricsService: metrics_service.MetricsService
    marketService: market_service.Service

    # Modules
    onboardingModule: onboarding_module.AccessInterface
    mainModule: main_module.AccessInterface

#################################################
# Forward declaration section
proc load(self: AppController)
proc buildAndRegisterLocalAccountSensitiveSettings(self: AppController)
proc buildAndRegisterUserProfile(self: AppController)
proc runPostOnboardingTasks(self: AppController)

# Startup Module Delegate Interface
proc onboardingDidLoad*(self: AppController)
proc userLoggedIn*(self: AppController): string
proc appReady*(self: AppController)
proc logout*(self: AppController)
proc finishAppLoading*(self: AppController)

# Main Module Delegate Interface
proc mainDidLoad*(self: AppController)
#################################################

proc connect(self: AppController) =
  self.statusFoundation.events.once("nodeStopped") do(a: Args):
    # not sure, but maybe we should take some actions when node stops
    discard

  # Handle runtime log level settings changes
  if not main_constants.runtimeLogLevelSet():
    self.statusFoundation.events.on(node_configuration_service.SIGNAL_NODE_LOG_LEVEL_UPDATE) do(a: Args):
      let args = NodeLogLevelUpdatedArgs(a)
      if args.logLevel == chronicles.LogLevel.DEBUG:
        setLogLevel(chronicles.LogLevel.DEBUG)
      elif defined(production):
        setLogLevel(chronicles.LogLevel.INFO)

proc loadServices(self: AppController) =
  # Services
  self.generalService = general_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool)
  self.keycardService = keycard_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool)
  self.keycardServiceV2 = keycard_serviceV2.newService(self.statusFoundation.events, self.statusFoundation.threadpool)
  self.nodeConfigurationService = node_configuration_service.newService(self.statusFoundation.events)
  self.keychainService = keychain_service.newService(self.statusFoundation.events)
  self.accountsService = accounts_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool)
  self.networkService = network_service.newService(self.statusFoundation.events, self.settingsService)
  self.contactsService = contacts_service.newService(
    self.statusFoundation.events, self.statusFoundation.threadpool, self.networkService, self.settingsService
  )
  self.chatService = chat_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool, self.contactsService)
  self.activityCenterService = activity_center_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool, self.chatService)
  self.tokenService = token_service.newService(
    self.statusFoundation.events, self.statusFoundation.threadpool, self.networkService, self.settingsService
  )
  self.collectibleService = collectible_service.newService(
    self.statusFoundation.events, self.statusFoundation.threadpool
  )
  self.currencyService = currency_service.newService(
    self.statusFoundation.events, self.statusFoundation.threadpool, self.tokenService, self.settingsService
  )
  self.walletAccountService = wallet_account_service.newService(
    self.statusFoundation.events, self.statusFoundation.threadpool, self.settingsService, self.accountsService,
    self.tokenService, self.networkService, self.currencyService
  )
  self.messageService = message_service.newService(
    self.statusFoundation.events,
    self.statusFoundation.threadpool,
    self.chatService,
    self.contactsService,
    self.tokenService,
    self.walletAccountService,
    self.networkService,
  )
  self.communityService = community_service.newService(self.statusFoundation.events,
    self.statusFoundation.threadpool, self.chatService, self.activityCenterService, self.messageService)
  self.rampService = ramp_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool)
  self.transactionService = transaction_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool,
    self.currencyService, self.networkService, self.settingsService, self.tokenService)
  self.bookmarkService = bookmark_service.newService(self.statusFoundation.events)
  self.profileService = profile_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool, self.settingsService)
  self.stickersService = stickers_service.newService(
    self.statusFoundation.events,
    self.statusFoundation.threadpool,
    self.settingsService,
    self.walletAccountService,
    self.transactionService,
    self.networkService,
    self.chatService,
    self.tokenService
  )
  self.aboutService = about_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool)
  self.dappPermissionsService = dapp_permissions_service.newService()
  self.languageService = language_service.newService(self.statusFoundation.events)
  self.privacyService = privacy_service.newService(self.statusFoundation.events, self.settingsService,
  self.accountsService)
  self.savedAddressService = saved_address_service.newService(self.statusFoundation.threadpool, self.statusFoundation.events,
    self.networkService, self.settingsService)
  self.devicesService = devices_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool,
    self.settingsService, self.accountsService, self.walletAccountService)
  self.mailserversService = mailservers_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool,
    self.settingsService, self.nodeConfigurationService)
  self.nodeService = node_service.newService(self.statusFoundation.events, self.settingsService, self.nodeConfigurationService)
  self.gifService = gif_service.newService(self.settingsService, self.statusFoundation.events, self.statusFoundation.threadpool)
  self.ensService = ens_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool,
    self.settingsService, self.walletAccountService, self.transactionService,
    self.networkService, self.tokenService)
  self.tokensService = tokens_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool,
    self.networkService, self.transactionService, self.tokenService, self.settingsService, self.walletAccountService,
    self.activityCenterService, self.communityService, self.currencyService)
  self.providerService = provider_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool, self.ensService)
  self.networkConnectionService = network_connection_service.newService(self.statusFoundation.events,
    self.walletAccountService, self.networkService, self.nodeService, self.tokenService)
  self.sharedUrlsService = shared_urls_service.newService(self.statusFoundation.events, self.statusFoundation.threadpool)
  self.marketService = market_service.newService(self.statusFoundation.events, self.settingsService)

proc unloadModules(self: AppController) =
  # Modules
  self.mainModule.unloadModules()
  self.mainModule.delete
  self.mainModule = nil

  self.accountsService.delete
  self.accountsService = nil
  self.chatService.delete
  self.chatService = nil
  self.communityService.delete
  self.communityService = nil
  self.currencyService.delete
  self.currencyService = nil
  self.collectibleService.delete
  self.collectibleService = nil
  self.tokenService.delete
  self.tokenService = nil
  self.rampService.delete
  self.rampService = nil
  self.transactionService.delete
  self.transactionService = nil
  self.walletAccountService.delete
  self.walletAccountService = nil
  self.aboutService.delete
  self.aboutService = nil
  self.networkService.delete
  self.networkService = nil
  self.activityCenterService.delete
  self.activityCenterService = nil
  self.dappPermissionsService.delete
  self.dappPermissionsService = nil
  self.providerService.delete
  self.providerService = nil
  self.nodeConfigurationService.delete
  self.nodeConfigurationService = nil
  self.nodeService.delete
  self.nodeService = nil
  self.settingsService.delete
  self.settingsService = nil
  self.stickersService.delete
  self.stickersService = nil
  self.savedAddressService.delete
  self.savedAddressService = nil
  self.devicesService.delete
  self.devicesService = nil
  self.mailserversService.delete
  self.mailserversService = nil
  self.messageService.delete
  self.messageService = nil
  self.privacyService.delete
  self.privacyService = nil
  self.profileService.delete
  self.profileService = nil
  self.generalService.delete
  self.generalService = nil
  self.ensService.delete
  self.ensService = nil
  self.tokensService.delete
  self.tokensService = nil
  self.keycardService.delete
  self.keycardService = nil
  self.keycardServiceV2.delete
  self.keycardServiceV2 = nil
  self.networkConnectionService.delete
  self.networkConnectionService = nil
  self.metricsService.delete
  self.metricsService = nil
  self.marketService.delete
  self.marketService = nil

  singletonInstance.engine.setRootContextProperty("localAppSettings", newQVariant())
  singletonInstance.engine.setRootContextProperty("localAccountSettings", newQVariant())
  singletonInstance.engine.setRootContextProperty("globalUtils", newQVariant())
  singletonInstance.engine.setRootContextProperty("metrics", newQVariant())
  singletonInstance.engine.setRootContextProperty("appSettings", newQVariant())
  singletonInstance.engine.setRootContextProperty("localAccountSensitiveSettings", newQVariant())
  singletonInstance.engine.setRootContextProperty("userProfile", newQVariant())

  self.appSettingsVariant.delete
  self.appSettingsVariant = nil
  self.localAppSettingsVariant.delete
  self.localAppSettingsVariant = nil
  self.localAccountSettingsVariant.delete
  self.localAccountSettingsVariant = nil
  self.localAccountSensitiveSettingsVariant.delete
  self.localAccountSensitiveSettingsVariant = nil
  self.userProfileVariant.delete
  self.userProfileVariant = nil
  self.globalUtilsVariant.delete
  self.globalUtilsVariant = nil
  self.metricsVariant.delete
  self.metricsVariant = nil

  when declared(GC_fullCollect):
    GC_fullCollect()

proc loadModules(self: AppController) =
  self.loadServices()
  self.mainModule = main_module.newModule[AppController](
    self,
    self.statusFoundation.events,
    self.statusFoundation.urlsManager,
    self.keychainService,
    self.accountsService,
    self.chatService,
    self.communityService,
    self.messageService,
    self.tokenService,
    self.collectibleService,
    self.currencyService,
    self.rampService,
    self.transactionService,
    self.walletAccountService,
    self.bookmarkService,
    self.profileService,
    self.settingsService,
    self.contactsService,
    self.aboutService,
    self.dappPermissionsService,
    self.languageService,
    self.privacyService,
    self.providerService,
    self.stickersService,
    self.activityCenterService,
    self.savedAddressService,
    self.nodeConfigurationService,
    self.devicesService,
    self.mailserversService,
    self.nodeService,
    self.gifService,
    self.ensService,
    self.tokensService,
    self.networkService,
    self.generalService,
    self.keycardService,
    self.networkConnectionService,
    self.sharedUrlsService,
    self.marketService,
    self.statusFoundation.threadpool
  )

proc newAppController*(statusFoundation: StatusFoundation): AppController =
  result = AppController()
  result.statusFoundation = statusFoundation

  # Preparing settings service to be exposed later as global QObject
  result.settingsService = settings_service.newService(statusFoundation.events)
  result.appSettingsVariant = newQVariant(result.settingsService)
  result.notificationsManager = newNotificationsManager(statusFoundation.events, result.settingsService)
  result.metricsService = metrics_service.newService(statusFoundation.threadpool)
  result.metricsVariant = newQVariant(result.metricsService)

  # Global
  result.localAppSettingsVariant = newQVariant(singletonInstance.localAppSettings)
  result.localAccountSettingsVariant = newQVariant(singletonInstance.localAccountSettings)
  result.localAccountSensitiveSettingsVariant = newQVariant(singletonInstance.localAccountSensitiveSettings)
  result.userProfileVariant = newQVariant(singletonInstance.userProfile)
  result.globalUtilsVariant = newQVariant(singletonInstance.utils)

  result.loadServices()
  result.onboardingModule = onboarding_module.newModule[AppController](
    result,
    statusFoundation.events,
    result.generalService,
    result.accountsService,
    result.walletAccountService,
    result.devicesService,
    result.keycardServiceV2,
  )

  result.mainModule = main_module.newModule[AppController](
    result,
    result.statusFoundation.events,
    result.statusFoundation.urlsManager,
    result.keychainService,
    result.accountsService,
    result.chatService,
    result.communityService,
    result.messageService,
    result.tokenService,
    result.collectibleService,
    result.currencyService,
    result.rampService,
    result.transactionService,
    result.walletAccountService,
    result.bookmarkService,
    result.profileService,
    result.settingsService,
    result.contactsService,
    result.aboutService,
    result.dappPermissionsService,
    result.languageService,
    result.privacyService,
    result.providerService,
    result.stickersService,
    result.activityCenterService,
    result.savedAddressService,
    result.nodeConfigurationService,
    result.devicesService,
    result.mailserversService,
    result.nodeService,
    result.gifService,
    result.ensService,
    result.tokensService,
    result.networkService,
    result.generalService,
    result.keycardService,
    result.networkConnectionService,
    result.sharedUrlsService,
    result.marketService,
    statusFoundation.threadpool
  )
  # Do connections
  result.connect()

proc delete*(self: AppController)
  info "logging out..."
  self.generalService.logout()
  self.unloadModules()

proc initializeQmlContext(self: AppController) =
  singletonInstance.engine.setRootContextProperty("localAppSettings", self.localAppSettingsVariant)
  singletonInstance.engine.setRootContextProperty("localAccountSettings", self.localAccountSettingsVariant)
  singletonInstance.engine.setRootContextProperty("globalUtils", self.globalUtilsVariant)
  singletonInstance.engine.setRootContextProperty("metrics", self.metricsVariant)
  singletonInstance.engine.load(newQUrl("qrc:///main.qml"))

  # We need to init a language service once qml is loaded
  self.languageService.init()

proc onboardingDidLoad*(self: AppController) =
  self.initializeQmlContext()

proc mainDidLoad*(self: AppController) =
  if not self.onboardingModule.isNil:
    self.runPostOnboardingTasks()

  # NB: after onboarding is finished, we need to switch back to the old service (Settings/Keycard)
  # TODO remove `keycardService` when everything is ported to `keycardServiceV2`
  self.keycardService.resetAPI()
  self.keycardService.init()

proc start*(self: AppController) =
  self.keycardServiceV2.init()
  self.keychainService.init()
  self.generalService.init()
  self.accountsService.init()
  self.devicesService.init()

  self.onboardingModule.load()

proc load(self: AppController) =
  self.settingsService.init()

  self.buildAndRegisterLocalAccountSensitiveSettings()
  self.buildAndRegisterUserProfile()

  self.notificationsManager.init()
  self.profileService.init()
  self.nodeConfigurationService.init()
  self.mailserversService.init()
  self.contactsService.init()
  self.chatService.init()
  self.messageService.init()
  self.communityService.init()
  self.providerService.init()
  self.rampService.init()
  self.bookmarkService.init()
  self.dappPermissionsService.init()
  self.providerService.init()
  self.transactionService.init()
  self.stickersService.init()
  self.activityCenterService.init()
  self.savedAddressService.init()
  self.aboutService.init()
  self.ensService.init()
  self.tokensService.init()
  self.gifService.init()
  self.networkConnectionService.init()
  self.marketService.init()

  # Accessible after user login
  singletonInstance.engine.setRootContextProperty("appSettings", self.appSettingsVariant)
  singletonInstance.engine.setRootContextProperty("globalUtils", self.globalUtilsVariant)

  self.networkService.init()
  self.tokenService.init()
  self.collectibleService.init()
  self.currencyService.init()
  self.walletAccountService.init()

  # Apply runtime log level settings
  if not main_constants.runtimeLogLevelSet():
    if self.nodeConfigurationService.isDebugEnabled():
      setLogLevel(chronicles.LogLevel.DEBUG)

  # load main module
  self.mainModule.load(
    self.statusFoundation.events,
    self.settingsService,
    self.nodeConfigurationService,
    self.contactsService,
    self.chatService,
    self.communityService,
    self.messageService,
    self.mailserversService,
  )

proc userLoggedIn*(self: AppController): string =
  try:
    self.generalService.startMessenger()
    return ""
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    return errDescription

proc appReady*(self: AppController) =
  self.statusFoundation.appReady()

proc finishAppLoading*(self: AppController) =
  self.load()

  if not self.onboardingModule.isNil:
    let account = self.accountsService.getLoggedInAccount()
    self.onboardingModule.onAppLoaded(account.keyUid)
    self.onboardingModule = nil

  self.mainModule.checkAndPerformProfileMigrationIfNeeded()

proc logout*(self: AppController) =
  self.generalService.logout()

proc buildAndRegisterLocalAccountSensitiveSettings(self: AppController) =
  var pubKey = self.settingsService.getPublicKey()
  singletonInstance.localAccountSensitiveSettings.setFileName(pubKey)
  singletonInstance.engine.setRootContextProperty("localAccountSensitiveSettings", self.localAccountSensitiveSettingsVariant)

proc buildAndRegisterUserProfile(self: AppController) =
  let pubKey = self.settingsService.getPublicKey()
  let alias = self.settingsService.getName()
  var preferredName = self.settingsService.getPreferredName()
  let displayName = self.settingsService.getDisplayName()
  let currentUserStatus = self.settingsService.getCurrentUserStatus()

  let loggedInAccount = self.accountsService.getLoggedInAccount()

  singletonInstance.userProfile.setFixedData(alias, loggedInAccount.keyUid, pubKey, loggedInAccount.keycardPairing.len > 0)
  singletonInstance.userProfile.setDisplayName(displayName)
  singletonInstance.userProfile.setPreferredName(preferredName)
  singletonInstance.userProfile.setThumbnailImage(loggedInAccount.images.thumbnail)
  singletonInstance.userProfile.setLargeImage(loggedInAccount.images.large)
  singletonInstance.userProfile.setCurrentUserStatus(currentUserStatus.statusType.int)

  singletonInstance.engine.setRootContextProperty("userProfile", self.userProfileVariant)

proc runPostOnboardingTasks(self: AppController) =
    debug "running post-onboarding tasks"

    let tasks = self.onboardingModule.getPostOnboardingTasks()
    for task in tasks:
      case task.kind:
      of kPostOnboardingTaskKeycardReplacement:
        KeycardReplacementTask(task).run(self.walletAccountService, self.keycardServiceV2)
      else:
        error "unknown post onboarding task"
