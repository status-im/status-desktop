import NimQml, os, strformat

import ../../app_service/common/utils

import ../../app_service/service/os_notification/service as os_notification_service
import ../../app_service/service/eth/service as eth_service
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
import ../../app_service/service/mnemonic/service as mnemonic_service
import ../../app_service/service/privacy/service as privacy_service
import ../../app_service/service/provider/service as provider_service
import ../../app_service/service/ens/service as ens_service
import ../../app_service/service/profile/service as profile_service
import ../../app_service/service/settings/service as settings_service
import ../../app_service/service/stickers/service as stickers_service
import ../../app_service/service/about/service as about_service
import ../../app_service/service/node_configuration/service as node_configuration_service
import ../../app_service/service/network/service as network_service

import ../modules/startup/module as startup_module
import ../modules/main/module as main_module

import ../global/local_account_settings
import ../global/global_singleton

import ../core/[main]

#################################################
# This will be removed later once we move to c++ and handle there async things
# and improved some services, like EventsService which should implement 
# provider/subscriber principe, similar we should have SettingsService.
import ../../constants
import eventemitter
import ../profile/core as profile
import ../chat/core as chat
import ../wallet/v1/core as wallet
import ../wallet/v2/core as walletV2
import ../node/core as node
import ../utilsView/core as utilsView
import ../keycard/core as keycard
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
    statusFoundation: StatusFoundation
    # Global
    localAppSettingsVariant: QVariant
    localAccountSettingsVariant: QVariant
    localAccountSensitiveSettingsVariant: QVariant
    userProfileVariant: QVariant

    # Services
    osNotificationService: os_notification_service.Service
    keychainService: keychain_service.Service
    ethService: eth_service.Service
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
    ensService: ens_service.Service
    providerService: provider_service.Service
    profileService: profile_service.Service
    settingsService: settings_service.Service
    stickersService: stickers_service.Service
    aboutService: about_service.Service
    networkService: network_service.Service
    languageService: language_service.Service
    mnemonicService: mnemonic_service.Service
    privacyService: privacy_service.Service
    nodeConfigurationService: node_configuration_service.Service

    # Modules
    startupModule: startup_module.AccessInterface
    mainModule: main_module.AccessInterface

    #################################################
    # At the end of refactoring this will be moved to appropriate place or removed:
    profile: ProfileController
    wallet: wallet.WalletController
    wallet2: walletV2.WalletController
    chat: ChatController
    node: NodeController
    utilsController: UtilsController
    keycard: KeycardController
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
# At the end of refactoring this will be moved to appropriate place or removed:
proc connect(self: AppController) =
  self.statusFoundation.status.events.once("loginCompleted") do(a: Args):
    var args = AccountArgs(a)
    self.statusFoundation.status.startMessenger()
    self.profile.init(args.account)
    self.wallet.init()
    self.wallet2.init()
    self.chat.init()
    self.utilsController.init()
    self.node.init()
    self.wallet.onLogin()

  self.statusFoundation.status.events.once("nodeStopped") do(a: Args):
    # TODO: remove this once accounts are not tracked in the AccountsModel
    self.statusFoundation.status.reset()
    # 2. Re-init controllers that don't require a running node
    self.keycard.init()
#################################################

proc newAppController*(statusFoundation: StatusFoundation): AppController =
  result = AppController()
  result.statusFoundation = statusFoundation

  # Global
  result.localAppSettingsVariant = newQVariant(singletonInstance.localAppSettings)
  result.localAccountSettingsVariant = newQVariant(singletonInstance.localAccountSettings)
  result.localAccountSensitiveSettingsVariant = newQVariant(singletonInstance.localAccountSensitiveSettings)
  result.userProfileVariant = newQVariant(singletonInstance.userProfile)

  # Services
  result.settingsService = settings_service.newService()
  result.nodeConfigurationService = node_configuration_service.newService(statusFoundation.fleetConfiguration, 
  result.settingsService)
  result.osNotificationService = os_notification_service.newService(statusFoundation.status.events)
  result.keychainService = keychain_service.newService(statusFoundation.status.events)
  result.ethService = eth_service.newService()
  result.accountsService = accounts_service.newService(statusFoundation.fleetConfiguration)
  result.networkService = network_service.newService()
  result.contactsService = contacts_service.newService(statusFoundation.status.events, statusFoundation.threadpool)
  result.chatService = chat_service.newService(result.contactsService)
  result.communityService = community_service.newService(result.chatService)
  result.messageService = message_service.newService(statusFoundation.status.events, statusFoundation.threadpool)
  result.tokenService = token_service.newService(statusFoundation.status.events, statusFoundation.threadpool, 
  result.settingsService)
  result.collectibleService = collectible_service.newService(result.settingsService)
  result.walletAccountService = wallet_account_service.newService(statusFoundation.status.events, result.settingsService, 
  result.tokenService)
  result.transactionService = transaction_service.newService(statusFoundation.status.events, statusFoundation.threadpool, 
  result.walletAccountService)
  result.bookmarkService = bookmark_service.newService()
  result.profileService = profile_service.newService()
  result.stickersService = stickers_service.newService(
    statusFoundation.status.events,
    statusFoundation.threadpool,
    result.ethService,
    result.settingsService,
    result.walletAccountService,
    result.transactionService,
    result.networkService,
    result.chatService
  )
  result.aboutService = about_service.newService()
  result.dappPermissionsService = dapp_permissions_service.newService()
  result.languageService = language_service.newService()
  result.mnemonicService = mnemonic_service.newService()
  result.privacyService = privacy_service.newService()
  result.ensService = ens_service.newService()
  result.providerService = provider_service.newService(result.dappPermissionsService, result.settingsService, result.ensService)

  # Modules
  result.startupModule = startup_module.newModule[AppController](
    result,
    statusFoundation.status.events,
    result.keychainService, 
    result.accountsService
  )
  result.mainModule = main_module.newModule[AppController](
    result, 
    statusFoundation.status.events,
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
    result.mnemonicService,
    result.privacyService,
    result.providerService,
    result.stickersService
  )

  #################################################
  # At the end of refactoring this will be moved to appropriate place or removed:
  result.profile = profile.newController(statusFoundation.status, statusFoundation, changeLanguage)
  result.wallet = wallet.newController(statusFoundation.status, statusFoundation)
  result.wallet2 = walletV2.newController(statusFoundation.status, statusFoundation)
  result.chat = chat.newController(statusFoundation.status, statusFoundation, OPENURI)
  result.node = node.newController(statusFoundation)
  result.utilsController = utilsView.newController(statusFoundation.status, statusFoundation)
  result.keycard = keycard.newController(statusFoundation.status)
  result.connect()
  #################################################

proc delete*(self: AppController) =
  self.osNotificationService.delete
  self.contactsService.delete
  self.chatService.delete
  self.communityService.delete
  self.bookmarkService.delete
  self.startupModule.delete
  self.mainModule.delete
  self.ethService.delete
  
  #################################################
  # At the end of refactoring this will be moved to appropriate place or removed:
  self.profile.delete
  self.wallet.delete
  self.wallet2.delete
  self.chat.delete
  self.node.delete
  self.utilsController.delete
  self.keycard.delete
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
  self.walletAccountService.delete
  self.aboutService.delete
  self.networkService.delete
  self.dappPermissionsService.delete
  self.providerService.delete
  self.ensService.delete
  self.nodeConfigurationService.delete
  self.settingsService.delete
  self.stickersService.delete

proc startupDidLoad*(self: AppController) =
  #################################################
  # At the end of refactoring this will be moved to appropriate place or removed:
  singletonInstance.engine.setRootContextProperty("profileModel", self.profile.variant)
  singletonInstance.engine.setRootContextProperty("walletModel", self.wallet.variant)
  singletonInstance.engine.setRootContextProperty("walletV2Model", self.wallet2.variant)
  singletonInstance.engine.setRootContextProperty("chatsModel", self.chat.variant)
  singletonInstance.engine.setRootContextProperty("nodeModel", self.node.variant)
  singletonInstance.engine.setRootContextProperty("utilsModel", self.utilsController.variant)
  singletonInstance.engine.setRootContextProperty("keycardModel", self.keycard.variant)
  #################################################

  singletonInstance.engine.setRootContextProperty("localAppSettings", self.localAppSettingsVariant)
  singletonInstance.engine.setRootContextProperty("localAccountSettings", self.localAccountSettingsVariant)
  singletonInstance.engine.load(newQUrl("qrc:///main.qml"))

  # We need to set a language once qml is loaded
  let locale = singletonInstance.localAppSettings.getLocale()
  setLanguage(locale)

proc mainDidLoad*(self: AppController) =
  self.statusFoundation.onLoggedIn()
  self.startupModule.moveToAppState()

  self.mainModule.checkForStoringPassword()

proc start*(self: AppController) =
  #################################################
  # At the end of refactoring this will be moved to appropriate place or removed:
  self.keycard.init()
  #################################################

  self.ethService.init()
  self.accountsService.init()
  
  self.startupModule.load()

proc load(self: AppController) =
  self.settingsService.init()
  self.nodeConfigurationService.init()
  self.contactsService.init()
  self.chatService.init()
  self.communityService.init()
  self.bookmarkService.init()
  self.tokenService.init()
  self.dappPermissionsService.init()
  self.ensService.init()
  self.providerService.init()
  self.walletAccountService.init()
  self.transactionService.init()
  self.languageService.init()
  self.stickersService.init()
  self.networkService.init()

  let pubKey = self.settingsService.getPublicKey()
  singletonInstance.localAccountSensitiveSettings.setFileName(pubKey)
  singletonInstance.engine.setRootContextProperty("localAccountSensitiveSettings", self.localAccountSensitiveSettingsVariant)

  # other global instances
  self.buildAndRegisterLocalAccountSensitiveSettings()  
  self.buildAndRegisterUserProfile()

  # load main module
  self.mainModule.load(
    self.statusFoundation.status.events,
    self.chatService,
    self.communityService,
    self.messageService
  )

proc userLoggedIn*(self: AppController) =
  #################################################
  # At the end of refactoring this will be removed:
  let loggedInUser = self.accountsService.getLoggedInAccount()
  let account = Account(name: loggedInUser.name, keyUid: loggedInUser.keyUid)
  self.statusFoundation.status.events.emit("loginCompleted", AccountArgs(account: account))
  #################################################
  self.load()

proc buildAndRegisterLocalAccountSensitiveSettings(self: AppController) = 
  var pubKey = self.settingsService.getPublicKey()
  singletonInstance.localAccountSensitiveSettings.setFileName(pubKey)
  singletonInstance.engine.setRootContextProperty("localAccountSensitiveSettings", self.localAccountSensitiveSettingsVariant)

proc buildAndRegisterUserProfile(self: AppController) = 
  let pubKey = self.settingsService.getPublicKey()
  let sendUserStatus = self.settingsService.getSendStatusUpdates()
  ## This is still not in use. Read a comment in UserProfile.
  ## let currentUserStatus = self.settingsService.getCurrentUserStatus()

  let loggedInAccount = self.accountsService.getLoggedInAccount()
  var thumbnail, large: string
  for img in loggedInAccount.images:
    if(img.imgType == "large"):
      large = img.uri
    elif(img.imgType == "thumbnail"):
      thumbnail = img.uri

  let meAsContact = self.contactsService.getContactById(pubKey)
  var ensName: string
  if(meAsContact.ensVerified):
    ensName = utils.prettyEnsName(meAsContact.name)

  singletonInstance.userProfile.setFixedData(loggedInAccount.name, loggedInAccount.keyUid, loggedInAccount.identicon, 
  pubKey)
  singletonInstance.userProfile.setEnsName(ensName)
  singletonInstance.userProfile.setThumbnailImage(thumbnail)
  singletonInstance.userProfile.setLargeImage(large)
  singletonInstance.userProfile.setUserStatus(sendUserStatus)

  singletonInstance.engine.setRootContextProperty("userProfile", self.userProfileVariant)
