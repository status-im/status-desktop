import NimQml, chronicles

import ../../app_service/service/general/service as general_service
import ../../app_service/service/keychain/service as keychain_service
import ../../app_service/service/accounts/service as accounts_service
import ../../app_service/service/contacts/service as contacts_service
import ../../app_service/service/language/service as language_service
import ../../app_service/service/chat/service as chat_service
import ../../app_service/service/community/service as community_service
import ../../app_service/service/message/service as message_service
import ../../app_service/service/token/service as token_service
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

import ../modules/startup/module as startup_module
import ../modules/main/module as main_module
import ../core/notifications/notifications_manager

import ../global/global_singleton

import ../core/[main]

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

    # Services
    generalService: general_service.Service
    keychainService: keychain_service.Service
    accountsService: accounts_service.Service
    contactsService: contacts_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service
    tokenService: token_service.Service
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

    # Modules
    startupModule: startup_module.AccessInterface
    mainModule: main_module.AccessInterface

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

proc connect(self: AppController) =
  self.statusFoundation.events.once("nodeStopped") do(a: Args):
    # not sure, but maybe we should take some actions when node stops
    discard

proc newAppController*(statusFoundation: StatusFoundation): AppController =
  result = AppController()
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
  result.generalService = general_service.newService()  
  result.nodeConfigurationService = node_configuration_service.newService(statusFoundation.fleetConfiguration,
  result.settingsService)
  result.keychainService = keychain_service.newService(statusFoundation.events)
  result.accountsService = accounts_service.newService(statusFoundation.fleetConfiguration)
  result.networkService = network_service.newService(statusFoundation.events, result.settingsService)
  result.contactsService = contacts_service.newService(
    statusFoundation.events, statusFoundation.threadpool, result.networkService, result.settingsService
  )
  result.chatService = chat_service.newService(statusFoundation.events, result.contactsService)
  result.communityService = community_service.newService(statusFoundation.events,
    statusFoundation.threadpool, result.chatService)
  result.activityCenterService = activity_center_service.newService(statusFoundation.events,
  statusFoundation.threadpool, result.chatService)
  result.tokenService = token_service.newService(
    statusFoundation.events, statusFoundation.threadpool, result.networkService
  )
  result.collectibleService = collectible_service.newService(result.networkService)
  result.walletAccountService = wallet_account_service.newService(
    statusFoundation.events, statusFoundation.threadpool, result.settingsService, result.accountsService,
    result.tokenService, result.networkService,
  )
  result.messageService = message_service.newService(
    statusFoundation.events, statusFoundation.threadpool, result.contactsService, result.tokenService, result.walletAccountService, result.networkService
  )
  result.transactionService = transaction_service.newService(statusFoundation.events, statusFoundation.threadpool, result.networkService, result.settingsService, result.tokenService)
  result.bookmarkService = bookmark_service.newService(statusFoundation.events)
  result.profileService = profile_service.newService(result.contactsService, result.settingsService)
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
  result.languageService = language_service.newService()
  # result.mnemonicService = mnemonic_service.newService()
  result.privacyService = privacy_service.newService(statusFoundation.events, result.settingsService,
  result.accountsService)
  result.savedAddressService = saved_address_service.newService(statusFoundation.events)
  result.devicesService = devices_service.newService(statusFoundation.events, result.settingsService)
  result.mailserversService = mailservers_service.newService(statusFoundation.events, statusFoundation.threadpool,
    result.settingsService, result.nodeConfigurationService, statusFoundation.fleetConfiguration)
  result.nodeService = node_service.newService(statusFoundation.events, statusFoundation.threadpool,
  result.settingsService)
  result.gifService = gif_service.newService(result.settingsService)
  result.ensService = ens_service.newService(statusFoundation.events, statusFoundation.threadpool,
    result.settingsService, result.walletAccountService, result.transactionService,
    result.networkService, result.tokenService)
  result.providerService = provider_service.newService(statusFoundation.events, statusFoundation.threadpool, result.ensService)

  # Modules
  result.startupModule = startup_module.newModule[AppController](
    result,
    statusFoundation.events,
    result.keychainService,
    result.accountsService,
    result.generalService
  )
  result.mainModule = main_module.newModule[AppController](
    result,
    statusFoundation.events,
    result.keychainService,
    result.accountsService,
    result.chatService,
    result.communityService,
    result.messageService,
    result.tokenService,
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
    result.networkService,
    result.generalService
  )

  # Do connections
  result.connect()

proc delete*(self: AppController) =
  singletonInstance.delete
  self.notificationsManager.delete
  self.keychainService.delete
  self.contactsService.delete
  self.bookmarkService.delete
  self.gifService.delete
  self.startupModule.delete
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
  self.gifService.delete

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
  self.startupModule.moveToAppState()

  self.mainModule.checkForStoringPassword()

proc start*(self: AppController) =
  self.keychainService.init()
  self.generalService.init()
  self.accountsService.init()

  self.startupModule.load()

proc load(self: AppController) =
  self.notificationsManager.init()

  self.settingsService.init()
  self.nodeConfigurationService.init()
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
  self.devicesService.init()
  self.mailserversService.init()
  self.ensService.init()
  self.gifService.init()

  # Accessible after user login
  singletonInstance.engine.setRootContextProperty("appSettings", self.appSettingsVariant)
  singletonInstance.engine.setRootContextProperty("globalUtils", self.globalUtilsVariant)

  self.buildAndRegisterLocalAccountSensitiveSettings()
  self.buildAndRegisterUserProfile()

  self.networkService.init()
  self.tokenService.init()
  self.walletAccountService.init()

  # load main module
  self.mainModule.load(
    self.statusFoundation.events,
    self.settingsService,
    self.contactsService,
    self.chatService,
    self.communityService,
    self.messageService,
    self.gifService,
    self.mailserversService,
  )

proc userLoggedIn*(self: AppController) =
  self.generalService.startMessenger()
  self.load()

  # Once user is logged in and main module is loaded we need to check if it gets here importing mnemonic or not
  # and delete mnemonic in the first case.
  let importedAccount = self.accountsService.getImportedAccount()
  if(importedAccount.isValid()):
    self.privacyService.removeMnemonic()

proc buildAndRegisterLocalAccountSensitiveSettings(self: AppController) =
  var pubKey = self.settingsService.getPublicKey()
  singletonInstance.localAccountSensitiveSettings.setFileName(pubKey)
  singletonInstance.engine.setRootContextProperty("localAccountSensitiveSettings", self.localAccountSensitiveSettingsVariant)

proc buildAndRegisterUserProfile(self: AppController) =
  let pubKey = self.settingsService.getPublicKey()
  let alias = self.settingsService.getName()
  let preferredName = self.settingsService.getPreferredName()
  var displayName = self.settingsService.getDisplayName()
  let ensUsernames = self.settingsService.getEnsUsernames()
  let firstEnsName = if (ensUsernames.len > 0): ensUsernames[0] else: ""
  let currentUserStatus = self.settingsService.getCurrentUserStatus()

  let loggedInAccount = self.accountsService.getLoggedInAccount()
  var thumbnail, large: string
  for img in loggedInAccount.images:
    if(img.imgType == "large"):
      large = img.uri
    elif(img.imgType == "thumbnail"):
      thumbnail = img.uri

  # loggedInAccount.name and displayName must be the same, if not, we are using loggedInAccount.name
  if (loggedInAccount.name != displayName):
    info "login account name and display name stored in settings differ"
    displayName = loggedInAccount.name

  singletonInstance.userProfile.setFixedData(alias, loggedInAccount.keyUid, pubKey)
  singletonInstance.userProfile.setDisplayName(displayName)
  singletonInstance.userProfile.setPreferredName(preferredName)
  singletonInstance.userProfile.setEnsName(firstEnsName)
  singletonInstance.userProfile.setFirstEnsName(firstEnsName)
  singletonInstance.userProfile.setThumbnailImage(thumbnail)
  singletonInstance.userProfile.setLargeImage(large)
  singletonInstance.userProfile.setCurrentUserStatus(currentUserStatus.statusType.int)

  singletonInstance.engine.setRootContextProperty("userProfile", self.userProfileVariant)
