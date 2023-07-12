import NimQml, sequtils, sugar, chronicles, os, uuids

import ../../app_service/service/general/service as general_service
import ../../app_service/service/keychain/service as keychain_service
import ../../app_service/service/keycard/service as keycard_service
import ../../app_service/service/accounts/service as accounts_service
import ../../app_service/service/contacts/service as contacts_service
import ../../app_service/service/language/service as language_service
import ../../app_service/service/chat/service as chat_service
import ../../app_service/service/community/service as community_service
import ../../app_service/service/message/service as message_service
import ../../app_service/service/token/service as token_service
import ../../app_service/service/currency/service as currency_service
import ../../app_service/service/transaction/service as transaction_service
import ../../app_service/service/collectible/service as collectible_service
import ../../app_service/service/wallet_account/service as wallet_account_service
import ../../app_service/service/bookmarks/service as bookmark_service
import ../../app_service/service/dapp_permissions/service as dapp_permissions_service
import ../../app_service/service/privacy/service as privacy_service
import ../../app_service/service/provider/service as provider_service
import ../../app_service/service/node/service as node_service
import ../../app_service/service/profile/service as profile_service
import ../../app_service/service/settings/service as settings_service
import ../../app_service/service/stickers/service as stickers_service
import ../../app_service/service/about/service as about_service
import ../../app_service/service/node_configuration/service as node_configuration_service
import ../../app_service/service/network/service as network_service
import ../../app_service/service/activity_center/service as activity_center_service
import ../../app_service/service/saved_address/service as saved_address_service
import ../../app_service/service/devices/service as devices_service
import ../../app_service/service/mailservers/service as mailservers_service
import ../../app_service/service/gif/service as gif_service
import ../../app_service/service/ens/service as ens_service
import ../../app_service/service/community_tokens/service as tokens_service
import ../../app_service/service/network_connection/service as network_connection_service

import ../modules/shared_modules/keycard_popup/module as keycard_shared_module
import ../modules/startup/module as startup_module
import ../modules/main/module as main_module
import ../core/notifications/notifications_manager
import ../../constants as main_constants
import ../global/global_singleton

import ../core/[main]

logScope:
  topics = "app-controller"

type
  AppController* = ref object of RootObj
    storeDefaultKeyPair: bool
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

    # Services
    generalService: general_service.Service
    keycardService*: keycard_service.Service
    keychainService: keychain_service.Service
    accountsService: accounts_service.Service
    contactsService: contacts_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service
    tokenService: token_service.Service
    currencyService: currency_service.Service
    transactionService: transaction_service.Service
    collectibleService: collectible_service.Service
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

    # Modules
    startupModule: startup_module.AccessInterface
    mainModule: main_module.AccessInterface

#################################################
# Forward declaration section
proc load(self: AppController)
proc buildAndRegisterLocalAccountSensitiveSettings(self: AppController)
proc buildAndRegisterUserProfile(self: AppController)
proc applyNecessaryActionsAfterLoggingIn(self: AppController)

# Startup Module Delegate Interface
proc startupDidLoad*(self: AppController)
proc userLoggedIn*(self: AppController, recoverAccount: bool): string
proc logout*(self: AppController)
proc finishAppLoading*(self: AppController)
proc storeDefaultKeyPairForNewKeycardUser*(self: AppController)
proc syncKeycardBasedOnAppWalletStateAfterLogin*(self: AppController)
proc applyKeycardReplacementAfterLogin*(self: AppController)
proc addToKeycardUidPairsToCheckForAChangeAfterLogin*(self: AppController, oldKeycardUid: string, newKeycardUid: string)
proc removeAllKeycardUidPairsForCheckingForAChangeAfterLogin*(self: AppController)

# Main Module Delegate Interface
proc mainDidLoad*(self: AppController)
#################################################

proc connect(self: AppController) =
  self.statusFoundation.events.once("nodeStopped") do(a: Args):
    # not sure, but maybe we should take some actions when node stops
    discard

  # Handle runtime log level settings changes
  if not existsEnv("LOG_LEVEL"):
    self.statusFoundation.events.on(node_configuration_service.SIGNAL_NODE_LOG_LEVEL_UPDATE) do(a: Args):
      let args = NodeLogLevelUpdatedArgs(a)
      if args.logLevel == LogLevel.DEBUG:
        setLogLevel(LogLevel.DEBUG)
      elif defined(production):
        setLogLevel(LogLevel.INFO)

proc newAppController*(statusFoundation: StatusFoundation): AppController =
  result = AppController()
  result.storeDefaultKeyPair = false
  result.syncKeycardBasedOnAppWalletState = false
  result.applyKeycardReplacement = false
  result.statusFoundation = statusFoundation

  # Preparing settings service to be exposed later as global QObject
  result.settingsService = settings_service.newService(statusFoundation.events)
  result.appSettingsVariant = newQVariant(result.settingsService)
  result.notificationsManager = newNotificationsManager(statusFoundation.events, result.settingsService)

  # Global
  result.localAppSettingsVariant = newQVariant(singletonInstance.localAppSettings)
  result.localAccountSettingsVariant = newQVariant(singletonInstance.localAccountSettings)
  result.localAccountSensitiveSettingsVariant = newQVariant(singletonInstance.localAccountSensitiveSettings)
  result.userProfileVariant = newQVariant(singletonInstance.userProfile)
  result.globalUtilsVariant = newQVariant(singletonInstance.utils)

  # Services
  result.generalService = general_service.newService(statusFoundation.events, statusFoundation.threadpool)
  result.activityCenterService = activity_center_service.newService(statusFoundation.events, statusFoundation.threadpool)
  result.keycardService = keycard_service.newService(statusFoundation.events, statusFoundation.threadpool)
  result.nodeConfigurationService = node_configuration_service.newService(statusFoundation.fleetConfiguration,
  result.settingsService, statusFoundation.events)
  result.keychainService = keychain_service.newService(statusFoundation.events)
  result.accountsService = accounts_service.newService(statusFoundation.events, statusFoundation.threadpool,
    statusFoundation.fleetConfiguration)
  result.networkService = network_service.newService(statusFoundation.events, result.settingsService)
  result.contactsService = contacts_service.newService(
    statusFoundation.events, statusFoundation.threadpool, result.networkService, result.settingsService,
    result.activityCenterService
  )
  result.chatService = chat_service.newService(statusFoundation.events, statusFoundation.threadpool, result.contactsService)
  result.tokenService = token_service.newService(
    statusFoundation.events, statusFoundation.threadpool, result.networkService
  )
  result.currencyService = currency_service.newService(
    statusFoundation.events, statusFoundation.threadpool, result.tokenService, result.settingsService
  )
  result.collectibleService = collectible_service.newService(statusFoundation.events, statusFoundation.threadpool, result.networkService)
  result.walletAccountService = wallet_account_service.newService(
    statusFoundation.events, statusFoundation.threadpool, result.settingsService, result.accountsService,
    result.tokenService, result.networkService
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
  result.transactionService = transaction_service.newService(statusFoundation.events, statusFoundation.threadpool, result.networkService, result.settingsService, result.tokenService)
  result.bookmarkService = bookmark_service.newService(statusFoundation.events)
  result.profileService = profile_service.newService(statusFoundation.events, result.settingsService)
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
  result.dappPermissionsService = dapp_permissions_service.newService()
  result.languageService = language_service.newService(statusFoundation.events)
  # result.mnemonicService = mnemonic_service.newService()
  result.privacyService = privacy_service.newService(statusFoundation.events, result.settingsService,
  result.accountsService)
  result.savedAddressService = saved_address_service.newService(statusFoundation.events, result.networkService, result.settingsService)
  result.devicesService = devices_service.newService(statusFoundation.events, statusFoundation.threadpool, result.settingsService, result.accountsService)
  result.mailserversService = mailservers_service.newService(statusFoundation.events, statusFoundation.threadpool,
    result.settingsService, result.nodeConfigurationService, statusFoundation.fleetConfiguration)
  result.nodeService = node_service.newService(statusFoundation.events, result.settingsService, result.nodeConfigurationService)
  result.gifService = gif_service.newService(result.settingsService, statusFoundation.events, statusFoundation.threadpool)
  result.ensService = ens_service.newService(statusFoundation.events, statusFoundation.threadpool,
    result.settingsService, result.walletAccountService, result.transactionService,
    result.networkService, result.tokenService)
  result.tokensService = tokens_service.newService(statusFoundation.events, statusFoundation.threadpool,
    result.transactionService, result.tokenService, result.settingsService, result.walletAccountService)
  result.providerService = provider_service.newService(statusFoundation.events, statusFoundation.threadpool, result.ensService)
  result.networkConnectionService = network_connection_service.newService(statusFoundation.events, result.walletAccountService, result.networkService, result.nodeService)

  # Modules
  result.startupModule = startup_module.newModule[AppController](
    result,
    statusFoundation.events,
    result.keychainService,
    result.accountsService,
    result.generalService,
    result.profileService,
    result.keycardService,
    result.devicesService,
  )
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
    result.currencyService,
    result.transactionService,
    result.collectibleService,
    result.walletAccountService,
    result.bookmarkService,
    result.profileService,
    result.settingsService,
    result.contactsService,
    result.aboutService,
    result.dappPermissionsService,
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
    result.networkConnectionService
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
  self.bookmarkService.delete
  self.gifService.delete
  if not self.startupModule.isNil:
    self.startupModule.delete
    self.startupModule = nil
  self.mainModule.delete
  self.languageService.delete

  self.appSettingsVariant.delete
  self.localAppSettingsVariant.delete
  self.localAccountSettingsVariant.delete
  self.localAccountSensitiveSettingsVariant.delete
  self.userProfileVariant.delete
  self.globalUtilsVariant.delete

  self.accountsService.delete
  self.chatService.delete
  self.communityService.delete
  self.currencyService.delete
  self.tokenService.delete
  self.transactionService.delete
  self.collectibleService.delete
  self.walletAccountService.delete
  self.aboutService.delete
  self.networkService.delete
  self.activityCenterService.delete
  self.dappPermissionsService.delete
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
  self.gifService.delete
  self.keycardService.delete
  self.networkConnectionService.delete

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

proc startupDidLoad*(self: AppController) =
  singletonInstance.engine.setRootContextProperty("localAppSettings", self.localAppSettingsVariant)
  singletonInstance.engine.setRootContextProperty("localAccountSettings", self.localAccountSettingsVariant)
  singletonInstance.engine.setRootContextProperty("globalUtils", self.globalUtilsVariant)
  singletonInstance.engine.load(newQUrl("qrc:///main.qml"))

  # We need to init a language service once qml is loaded
  self.languageService.init()
  # We need this to set app width/height appropriatelly on the app start.
  self.startupModule.startUpUIRaised()

proc mainDidLoad*(self: AppController) =
  self.applyNecessaryActionsAfterLoggingIn()
  self.startupModule.moveToAppState()
  self.checkForStoringPasswordToKeychain()

proc start*(self: AppController) =
  self.keycardService.init()
  self.keychainService.init()
  self.generalService.init()
  self.accountsService.init()
  self.devicesService.init()

  self.startupModule.load()

proc load(self: AppController) =
  self.notificationsManager.init()

  self.settingsService.init()
  self.profileService.init()
  self.nodeConfigurationService.init()
  self.mailserversService.init()
  self.contactsService.init()
  self.chatService.init()
  self.messageService.init()
  self.communityService.init()
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

  # Accessible after user login
  singletonInstance.engine.setRootContextProperty("appSettings", self.appSettingsVariant)
  singletonInstance.engine.setRootContextProperty("globalUtils", self.globalUtilsVariant)

  self.buildAndRegisterLocalAccountSensitiveSettings()
  self.buildAndRegisterUserProfile()

  self.networkService.init()
  self.tokenService.init()
  self.currencyService.init()
  self.walletAccountService.init()
  self.collectibleService.init()

  # Apply runtime log level settings
  if not existsEnv("LOG_LEVEL"):
    if self.nodeConfigurationService.isDebugEnabled():
      setLogLevel(LogLevel.DEBUG)

  # load main module
  self.mainModule.load(
    self.statusFoundation.events,
    self.settingsService,
    self.nodeConfigurationService,
    self.contactsService,
    self.chatService,
    self.communityService,
    self.messageService,
    self.gifService,
    self.mailserversService,
  )

proc userLoggedIn*(self: AppController, recoverAccount: bool): string =
  try:
    self.generalService.startMessenger()
    self.statusFoundation.userLoggedIn(recoverAccount)
    return ""
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    return errDescription

proc finishAppLoading*(self: AppController) =
  self.load()

  # Once user is logged in and main module is loaded we need to check if it gets here importing mnemonic or not
  # and delete mnemonic in the first case.
  let importedAccount = self.accountsService.getImportedAccount()
  if(importedAccount.isValid()):
    self.privacyService.removeMnemonic()

  if not self.startupModule.isNil:
    self.startupModule.delete
    self.startupModule = nil

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

proc storeDefaultKeyPairForNewKeycardUser*(self: AppController) =
  self.storeDefaultKeyPair = true

proc syncKeycardBasedOnAppWalletStateAfterLogin*(self: AppController) =
  self.syncKeycardBasedOnAppWalletState = true

proc applyKeycardReplacementAfterLogin*(self: AppController) =
  self.applyKeycardReplacement = true

proc addToKeycardUidPairsToCheckForAChangeAfterLogin*(self: AppController, oldKeycardUid: string, newKeycardUid: string) =
  self.changedKeycardUids.add((oldKcUid: oldKeycardUid, newKcUid: newKeycardUid))

proc removeAllKeycardUidPairsForCheckingForAChangeAfterLogin*(self: AppController) =
  self.changedKeycardUids = @[]
