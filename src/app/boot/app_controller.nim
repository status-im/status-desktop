import NimQml, sequtils, sugar, chronicles, uuids

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

import app/modules/shared_modules/keycard_popup/module as keycard_shared_module
import app/modules/startup/module as startup_module
import app/modules/onboarding/module as onboarding_module
import app/modules/onboarding/post_onboarding/[keycard_replacement_task, keycard_convert_account]
import app/modules/main/module as main_module
import app/core/notifications/notifications_manager
import app/global/[global_singleton, feature_flags]
import app/global/app_signals
import app/core/[main]

import constants as main_constants

logScope:
  topics = "app-controller"

type
  AppController* = ref object of RootObj
    syncKeycardBasedOnAppWalletState: bool
    applyKeycardReplacement: bool
    changedKeycardUids: seq[tuple[oldKcUid: string, newKcUid: string]] # used in case user unlocked keycard during onboarding using seed phrase
    statusFoundation: StatusFoundation
    notificationsManager*: NotificationsManager
    keychainConnectionIds: seq[UUID]

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
    providerService: provider_service.Service
    profileService: profile_service.Service
    settingsService: settings_service.Service
    stickersService: stickers_service.Service
    aboutService: about_service.Service
    networkService: network_service.Service
    activityCenterService: activity_center_service.Service
    languageService: language_service.Service
    # mnemonicService: mnemonic_service.Service
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

    # Modules
    startupModule: startup_module.AccessInterface
    onboardingModule: onboarding_module.AccessInterface
    mainModule: main_module.AccessInterface

#################################################
# Forward declaration section
proc load(self: AppController)
proc buildAndRegisterLocalAccountSensitiveSettings(self: AppController)
proc buildAndRegisterUserProfile(self: AppController)
proc applyNecessaryActionsAfterLoggingIn(self: AppController)
proc runPostOnboardingTasks(self: AppController)

# Startup Module Delegate Interface
proc startupDidLoad*(self: AppController)
proc onboardingDidLoad*(self: AppController)
proc userLoggedIn*(self: AppController): string
proc appReady*(self: AppController)
proc logout*(self: AppController)
proc finishAppLoading*(self: AppController)
proc syncKeycardBasedOnAppWalletStateAfterLogin*(self: AppController)
proc applyKeycardReplacementAfterLogin*(self: AppController)
proc addToKeycardUidPairsToCheckForAChangeAfterLogin*(self: AppController, oldKeycardUid: string, newKeycardUid: string)
proc removeAllKeycardUidPairsForCheckingForAChangeAfterLogin*(self: AppController)

proc createStartupModule(self: AppController, statusFoundation: StatusFoundation): startup_module.Module[AppController]

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

# TODO remove this function once we have only the new onboarding module
proc shouldUseTheNewOnboardingModule(self: AppController): bool =
  return singletonInstance.featureFlags().getOnboardingV2Enabled()

proc newAppController*(statusFoundation: StatusFoundation): AppController =
  result = AppController()
  result.syncKeycardBasedOnAppWalletState = false
  result.applyKeycardReplacement = false
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

  # Services
  result.generalService = general_service.newService(statusFoundation.events, statusFoundation.threadpool)
  result.keycardService = keycard_service.newService(statusFoundation.events, statusFoundation.threadpool)
  result.keycardServiceV2 = keycard_serviceV2.newService(statusFoundation.events, statusFoundation.threadpool)
  result.nodeConfigurationService = node_configuration_service.newService(statusFoundation.fleetConfiguration,
  result.settingsService, statusFoundation.events)
  result.keychainService = keychain_service.newService(statusFoundation.events)
  result.accountsService = accounts_service.newService(statusFoundation.events, statusFoundation.threadpool,
    statusFoundation.fleetConfiguration)
  result.networkService = network_service.newService(statusFoundation.events, result.settingsService)
  result.contactsService = contacts_service.newService(
    statusFoundation.events, statusFoundation.threadpool, result.networkService, result.settingsService
  )
  result.chatService = chat_service.newService(statusFoundation.events, statusFoundation.threadpool, result.contactsService)
  result.activityCenterService = activity_center_service.newService(statusFoundation.events, statusFoundation.threadpool, result.chatService)
  result.tokenService = token_service.newService(
    statusFoundation.events, statusFoundation.threadpool, result.networkService, result.settingsService
  )
  result.collectibleService = collectible_service.newService(
    statusFoundation.events, statusFoundation.threadpool
  )
  result.currencyService = currency_service.newService(
    statusFoundation.events, statusFoundation.threadpool, result.tokenService, result.settingsService
  )
  result.walletAccountService = wallet_account_service.newService(
    statusFoundation.events, statusFoundation.threadpool, result.settingsService, result.accountsService,
    result.tokenService, result.networkService, result.currencyService
  )
  result.messageService = message_service.newService(
    statusFoundation.events,
    statusFoundation.threadpool,
    result.chatService,
    result.contactsService,
    result.tokenService,
    result.walletAccountService,
    result.networkService,
  )
  result.communityService = community_service.newService(statusFoundation.events,
    statusFoundation.threadpool, result.chatService, result.activityCenterService, result.messageService)
  result.rampService = ramp_service.newService(statusFoundation.events, statusFoundation.threadpool)
  result.transactionService = transaction_service.newService(statusFoundation.events, statusFoundation.threadpool,
    result.currencyService, result.networkService, result.settingsService, result.tokenService)
  result.profileService = profile_service.newService(statusFoundation.events, statusFoundation.threadpool, result.settingsService)
  result.stickersService = stickers_service.newService(
    statusFoundation.events,
    statusFoundation.threadpool,
    result.settingsService,
    result.walletAccountService,
    result.transactionService,
    result.networkService,
    result.chatService,
    result.tokenService
  )
  result.aboutService = about_service.newService(statusFoundation.events, statusFoundation.threadpool)
  result.languageService = language_service.newService(statusFoundation.events)
  # result.mnemonicService = mnemonic_service.newService()
  result.privacyService = privacy_service.newService(statusFoundation.events, result.settingsService,
  result.accountsService)
  result.savedAddressService = saved_address_service.newService(statusFoundation.threadpool, statusFoundation.events,
    result.networkService, result.settingsService)
  result.devicesService = devices_service.newService(statusFoundation.events, statusFoundation.threadpool,
    result.settingsService, result.accountsService, result.walletAccountService)
  result.mailserversService = mailservers_service.newService(statusFoundation.events, statusFoundation.threadpool,
    result.settingsService, result.nodeConfigurationService, statusFoundation.fleetConfiguration)
  result.nodeService = node_service.newService(statusFoundation.events, result.settingsService, result.nodeConfigurationService)
  result.gifService = gif_service.newService(result.settingsService, statusFoundation.events, statusFoundation.threadpool)
  result.ensService = ens_service.newService(statusFoundation.events, statusFoundation.threadpool,
    result.settingsService, result.walletAccountService, result.transactionService,
    result.networkService, result.tokenService)
  result.tokensService = tokens_service.newService(statusFoundation.events, statusFoundation.threadpool,
    result.networkService, result.transactionService, result.tokenService, result.settingsService, result.walletAccountService,
    result.activityCenterService, result.communityService, result.currencyService)
  result.providerService = provider_service.newService(statusFoundation.events, statusFoundation.threadpool, result.ensService)
  result.networkConnectionService = network_connection_service.newService(statusFoundation.events,
    result.walletAccountService, result.networkService, result.nodeService, result.tokenService)
  result.sharedUrlsService = shared_urls_service.newService(statusFoundation.events, statusFoundation.threadpool)
  # Modules
  if result.shouldUseTheNewOnboardingModule():
    result.onboardingModule = onboarding_module.newModule[AppController](
      result,
      statusFoundation.events,
      result.generalService,
      result.accountsService,
      result.walletAccountService,
      result.devicesService,
      result.keycardServiceV2,
    )
  else:
    result.startupModule = result.createStartupModule(statusFoundation)
  result.mainModule = main_module.newModule[AppController](
    result,
    statusFoundation.events,
    statusFoundation.urlsManager,
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
    result.profileService,
    result.settingsService,
    result.contactsService,
    result.aboutService,
    result.languageService,
    # result.mnemonicService,
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
    statusFoundation.threadpool
  )

  # Do connections
  result.connect()

proc delete*(self: AppController) =
  info "logging out..."
  self.generalService.logout()

  singletonInstance.delete
  self.notificationsManager.delete
  self.keychainService.delete
  self.contactsService.delete
  self.gifService.delete
  if not self.startupModule.isNil:
    self.startupModule.delete
    self.startupModule = nil
  if not self.onboardingModule.isNil:
    self.onboardingModule.delete
    self.onboardingModule = nil
  self.mainModule.delete
  self.languageService.delete

  self.appSettingsVariant.delete
  self.localAppSettingsVariant.delete
  self.localAccountSettingsVariant.delete
  self.localAccountSensitiveSettingsVariant.delete
  self.userProfileVariant.delete
  self.globalUtilsVariant.delete
  self.metricsVariant.delete

  self.accountsService.delete
  self.chatService.delete
  self.communityService.delete
  self.currencyService.delete
  self.collectibleService.delete
  self.tokenService.delete
  self.rampService.delete
  self.transactionService.delete
  self.walletAccountService.delete
  self.aboutService.delete
  self.networkService.delete
  self.activityCenterService.delete
  self.providerService.delete
  self.nodeConfigurationService.delete
  self.nodeService.delete
  self.settingsService.delete
  self.stickersService.delete
  self.savedAddressService.delete
  self.devicesService.delete
  self.mailserversService.delete
  self.messageService.delete
  self.privacyService.delete
  self.profileService.delete
  self.generalService.delete
  self.ensService.delete
  self.tokensService.delete
  self.keycardService.delete
  self.keycardServiceV2.delete
  self.networkConnectionService.delete
  self.metricsService.delete

# TODO: This function can be removed when we completely switch to the new onboarding module
proc createStartupModule(self: AppController, statusFoundation: StatusFoundation): startup_module.Module[AppController] =
  return startup_module.newModule[AppController](
    self,
    statusFoundation.events,
    self.keychainService,
    self.accountsService,
    self.generalService,
    self.profileService,
    self.keycardService,
    self.devicesService
  )

proc disconnectKeychain(self: AppController) =
  for id in self.keychainConnectionIds:
    self.statusFoundation.events.disconnect(id)
  self.keychainConnectionIds = @[]

proc connectKeychain(self: AppController) =
  var handlerId = self.statusFoundation.events.onWithUUID(SIGNAL_KEYCHAIN_SERVICE_SUCCESS) do(e:Args):
    let args = KeyChainServiceArg(e)
    self.disconnectKeychain()
    ## we need to set local `storeToKeychain` prop to `store` value since in this context means pass/pin is stored well
    singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_STORE)
  self.keychainConnectionIds.add(handlerId)

  handlerId = self.statusFoundation.events.onWithUUID(SIGNAL_KEYCHAIN_SERVICE_ERROR) do(e:Args):
    let args = KeyChainServiceArg(e)
    self.disconnectKeychain()
    ## no need for any other activity in this context, local `storeToKeychain` prop remains as it was
    ## maybe in some point in future we add a popup letting user know about this
    info "unable to store the data to keychain", errCode=args.errCode, errType=args.errType, errDesc=args.errDescription
  self.keychainConnectionIds.add(handlerId)

proc checkForStoringPasswordToKeychain(self: AppController) =
  if singletonInstance.localAppSettings.getTestEnvironment():
    return
  ## This proc is used to store pass/pin depends on user's selection during onboarding flow.
  let account = self.accountsService.getLoggedInAccount()
  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if not main_constants.SUPPORTS_FINGERPRINT or # This is MacOS only feature
    value == LS_VALUE_STORE or # means pass is already stored, no need to store it again
    value == LS_VALUE_NEVER or # means pass doesn't need to be stored at all
    account.name.len == 0:
      return
  # We are here if stored "storeToKeychain" property for the logged in user is either empty or set to "NotNow".

  self.connectKeychain()
  let pass = self.startupModule.getPassword()
  if pass.len > 0:
    self.keychainService.storeData(account.keyUid, pass)
  else:
    self.keychainService.storeData(account.keyUid, self.startupModule.getPin())

proc initializeQmlContext(self: AppController) =
  singletonInstance.engine.setRootContextProperty("localAppSettings", self.localAppSettingsVariant)
  singletonInstance.engine.setRootContextProperty("localAccountSettings", self.localAccountSettingsVariant)
  singletonInstance.engine.setRootContextProperty("globalUtils", self.globalUtilsVariant)
  singletonInstance.engine.setRootContextProperty("metrics", self.metricsVariant)
  singletonInstance.engine.load(newQUrl("qrc:///main.qml"))

  # We need to init a language service once qml is loaded
  self.languageService.init()
  # We need this to set app width/height appropriately on the app start.
  if not self.startupModule.isNil:
    self.startupModule.startUpUIRaised()

proc startupDidLoad*(self: AppController) =
  self.initializeQmlContext()

proc onboardingDidLoad*(self: AppController) =
  self.initializeQmlContext()

proc switchToOldOnboarding*(self: AppController) =
  if not self.shouldUseTheNewOnboardingModule():
    return
  self.keycardService.resetAPI()
  self.startupModule = self.createStartupModule(self.statusFoundation)
  self.keycardService.init()

proc mainDidLoad*(self: AppController) =
  if not self.startupModule.isNil:
    self.applyNecessaryActionsAfterLoggingIn()
    self.startupModule.moveToAppState()
    self.checkForStoringPasswordToKeychain()

  if not self.onboardingModule.isNil:
    self.switchToOldOnboarding()
    self.runPostOnboardingTasks()
proc start*(self: AppController) =
  if self.shouldUseTheNewOnboardingModule():
    self.keycardServiceV2.init()
  else:
    self.keycardService.init()

  self.keychainService.init()
  self.generalService.init()
  self.accountsService.init()
  self.devicesService.init()

  if self.shouldUseTheNewOnboardingModule():
    self.onboardingModule.load()
  else:
    self.startupModule.load()

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
  self.transactionService.init()
  self.stickersService.init()
  self.activityCenterService.init()
  self.savedAddressService.init()
  self.aboutService.init()
  self.ensService.init()
  self.tokensService.init()
  self.gifService.init()
  self.networkConnectionService.init()

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

  if not self.startupModule.isNil:
    self.startupModule.onAppLoaded()
    self.startupModule = nil

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
  var thumbnail, large: string
  for img in loggedInAccount.images:
    if(img.imgType == "large"):
      large = img.uri
    elif(img.imgType == "thumbnail"):
      thumbnail = img.uri

  singletonInstance.userProfile.setFixedData(alias, loggedInAccount.keyUid, pubKey, loggedInAccount.keycardPairing.len > 0)
  singletonInstance.userProfile.setDisplayName(displayName)
  singletonInstance.userProfile.setPreferredName(preferredName)
  singletonInstance.userProfile.setThumbnailImage(thumbnail)
  singletonInstance.userProfile.setLargeImage(large)
  singletonInstance.userProfile.setCurrentUserStatus(currentUserStatus.statusType.int)

  singletonInstance.engine.setRootContextProperty("userProfile", self.userProfileVariant)

proc doKeycardReplacement(self: AppController) =
  let keyUid = singletonInstance.userProfile.getKeyUid()
  let keypair = self.walletAccountService.getKeypairByKeyUid(keyUid)
  if keypair.isNil:
    error "cannot resolve appropriate keypair for logged in user"
    return
  let (_, flowEvent) = self.keycardService.getLastReceivedKeycardData()
  let instanceUid = flowEvent.instanceUID
  let pin = self.startupModule.getPin()
  if instanceUid.len == 0 or
    keyUid != flowEvent.keyUid or
    pin.len != PINLengthForStatusApp:
      info "keycard replacement process is not fully completed, try the same again"
      return
  # we have to delete all keycards with the same key uid to cover the case if user had more then a single keycard for the same keypair
  discard self.walletAccountService.deleteAllKeycardsWithKeyUid(singletonInstance.userProfile.getKeyUid())
  # store new keycard with accounts, in this context no need to check if accounts match the default Status derivation path,
  # cause otherwise we wouldn't be here (cannot have keycard profile with any such path)
  let accountsAddresses = keypair.accounts.filter(acc => not acc.isChat).map(acc => acc.address)
  let keycard = KeycardDto(
    keycardUid: instanceUid,
    keycardName: keypair.name,
    keyUid: keyUid,
    accountsAddresses: accountsAddresses
  )
  discard self.walletAccountService.addKeycardOrAccounts(keycard, accountsComingFromKeycard = true)
  # store metadata to a Keycard
  let accountsPathsToStore = keypair.accounts.filter(acc => not acc.isChat).map(acc => acc.path)
  self.keycardService.startStoreMetadataFlow(keypair.name, self.startupModule.getPin(), accountsPathsToStore)
  info "keycard replacement fully done"

proc runPostOnboardingTasks(self: AppController) =
    debug "running post-onboarding tasks"

    let tasks = self.onboardingModule.getPostOnboardingTasks()
    for task in tasks:
      case task.kind:
      of kPostOnboardingTaskKeycardReplacement:
        KeycardReplacementTask(task).run(self.walletAccountService, self.keycardServiceV2)
      of kConvertKeycardAccountToRegular:
        KeycardConvertAccountTask(task).run(self.accountsService)
      else:
        error "unknown post onboarding task"

proc applyNecessaryActionsAfterLoggingIn(self: AppController) =
  if self.applyKeycardReplacement:
    self.doKeycardReplacement()
    return
  ##############################################################################                                             store def   kc sync with app    kc uid
  ## Onboarding flows sync keycard state after login                                                                          keypair  | (inc. kp store)  |  update
  ## `I’m new to Status` -> `Generate new keys`                                                                          ->     na     |       na         |    na
  ## `I’m new to Status` -> `Generate keys for a new Keycard`                                                            ->    yes     |       no         |    no
  ## `I’m new to Status` -> `Import a seed phrase` -> `Import a seed phrase`                                             ->     na     |       na         |    na
  ## `I’m new to Status` -> `Import a seed phrase` -> `Import a seed phrase into a new Keycard`                          ->    yes     |       no         |    no
  ##
  ## `I already use Status` -> `Scan sync code`                                                                          -> flow not developed yet
  ## `I already use Status` -> `I don’t have other device` -> `Login with Keycard` (fetched)                             ->     no     |      yes         |    no
  ## `I already use Status` -> `I don’t have other device` -> `Login with Keycard` (unlock via puk, fetched)             ->     no     |      yes         |    no
  ## `I already use Status` -> `I don’t have other device` -> `Login with Keycard` (unlock via seed phrase, fetched)     ->     no     |      yes         |   yes (kc details should be fetched and set to db while recovering, that's the reason why)
  ## `I already use Status` -> `I don’t have other device` -> `Login with Keycard` (not fetched)                         ->     no     |      yes         |    no
  ## `I already use Status` -> `I don’t have other device` -> `Login with Keycard` (unlock via puk, not fetched)         ->     no     |      yes         |    no
  ## `I already use Status` -> `I don’t have other device` -> `Login with Keycard` (unlock via seed phrase, not fetched) ->     no     |      yes         |    no
  ## `I already use Status` -> `I don’t have other device` -> `Enter a seed phrase`                                      ->     na     |       na         |    na
  ##
  ## `Login`                                                                                                             ->     na     |       na         |    na
  ## `Login` -> if card was unlocked via puk                                                                             ->     na     |       na         |    na
  ## `Login` -> if card was unlocked via seed phrase                                                                     ->     no     |       no         |   yes
  ## `Login` -> `Create replacement Keycard with seed phrase`                                                            ->     no     |      yes         |    no (we don't know which kc is replaced if user has more kc for the same kp)
  ##############################################################################
  if singletonInstance.userProfile.getIsKeycardUser() or
    self.syncKeycardBasedOnAppWalletState:
      let data = SharedKeycarModuleArgs(
        pin: self.startupModule.getPin(),
        keyUid: singletonInstance.userProfile.getKeyUid()
      )
      self.statusFoundation.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_TRY_KEYCARD_SYNC, data)

  if self.changedKeycardUids.len > 0:
    let oldUid = self.changedKeycardUids[0].oldKcUid
    let newUid = self.changedKeycardUids[^1].newKcUid
    discard self.walletAccountService.updateKeycardUid(oldUid, newUid)
    discard self.walletAccountService.setKeycardUnlocked(singletonInstance.userProfile.getKeyUid(), newUid)

proc syncKeycardBasedOnAppWalletStateAfterLogin*(self: AppController) =
  self.syncKeycardBasedOnAppWalletState = true

proc applyKeycardReplacementAfterLogin*(self: AppController) =
  self.applyKeycardReplacement = true

proc addToKeycardUidPairsToCheckForAChangeAfterLogin*(self: AppController, oldKeycardUid: string, newKeycardUid: string) =
  self.changedKeycardUids.add((oldKcUid: oldKeycardUid, newKcUid: newKeycardUid))

proc removeAllKeycardUidPairsForCheckingForAChangeAfterLogin*(self: AppController) =
  self.changedKeycardUids = @[]
