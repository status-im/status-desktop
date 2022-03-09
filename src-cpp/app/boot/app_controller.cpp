#include "app_controller.h"
#include "accounts/service_accounts.h"
#include "app_service.h"
#include "modules/main/module_main.h"
#include "modules/startup/module_startup.h"
#include <QDebug>

AppController::AppController()
{
    // result.statusFoundation = statusFoundation

    // # Global
    // result.localAppSettingsVariant = newQVariant(singletonInstance.localAppSettings)
    // result.localAccountSettingsVariant = newQVariant(singletonInstance.localAccountSettings)
    // result.localAccountSensitiveSettingsVariant = newQVariant(singletonInstance.localAccountSensitiveSettings)
    // result.userProfileVariant = newQVariant(singletonInstance.userProfile)
    // result.globalUtilsVariant = newQVariant(singletonInstance.utils)

    // # Services
    // result.settingsService = settings_service.newService()
    // result.nodeConfigurationService = node_configuration_service.newService(statusFoundation.fleetConfiguration,
    // result.settingsService)
    // result.osNotificationService = os_notification_service.newService(statusFoundation.status.events)
    // result.keychainService = keychain_service.newService(statusFoundation.status.events)
    // result.ethService = eth_service.newService()
    m_accountsService = new Accounts::Service();
    m_walletServicePtr = std::make_shared<Wallets::Service>();
    // result.networkService = network_service.newService()
    // result.contactsService = contacts_service.newService(statusFoundation.status.events, statusFoundation.threadpool)
    // result.chatService = chat_service.newService(statusFoundation.status.events, result.contactsService)
    // result.communityService = community_service.newService(statusFoundation.status.events)
    // result.messageService = message_service.newService(statusFoundation.status.events, statusFoundation.threadpool)
    // result.activityCenterService = activity_center_service.newService(statusFoundation.status.events,
    // statusFoundation.threadpool, result.chatService)
    // result.tokenService = token_service.newService(statusFoundation.status.events, statusFoundation.threadpool,
    // result.settingsService)
    // result.collectibleService = collectible_service.newService(result.settingsService)
    // result.walletAccountService = wallet_account_service.newService(statusFoundation.status.events, result.settingsService,
    // result.accountsService, result.tokenService)
    // result.transactionService = transaction_service.newService(statusFoundation.status.events, statusFoundation.threadpool,
    // result.walletAccountService)
    // result.bookmarkService = bookmark_service.newService()
    // result.profileService = profile_service.newService()
    // result.stickersService = stickers_service.newService(
    // statusFoundation.status.events,
    // statusFoundation.threadpool,
    // result.ethService,
    // result.settingsService,
    // result.walletAccountService,
    // result.transactionService,
    // result.networkService,
    // result.chatService
    // )
    // result.aboutService = about_service.newService(statusFoundation.status.events, statusFoundation.threadpool,
    // result.settingsService)
    // result.dappPermissionsService = dapp_permissions_service.newService()
    // result.languageService = language_service.newService()
    // # result.mnemonicService = mnemonic_service.newService()
    // result.privacyService = privacy_service.newService(statusFoundation.status.events, result.settingsService,
    // result.accountsService)
    // result.providerService = provider_service.newService(result.dappPermissionsService, result.settingsService)
    // result.savedAddressService = saved_address_service.newService(statusFoundation.status.events)
    // result.devicesService = devices_service.newService(statusFoundation.status.events, result.settingsService)
    // result.mailserversService = mailservers_service.newService(statusFoundation.status.events, statusFoundation.marathon,
    // result.settingsService, result.nodeConfigurationService, statusFoundation.fleetConfiguration)

    // # Modules
    m_startupModule = new Modules::Startup::Module(this, /*keychainService,*/ m_accountsService);

    m_mainModulePtr = new Modules::Main::Module(m_walletServicePtr, this);
    // statusFoundation.status.events,
    // result.keychainService,
    // result.accountsService,
    // result.chatService,
    // result.communityService,
    // result.messageService,
    // result.tokenService,
    // result.transactionService,
    // result.collectibleService,
    // result.walletAccountService,
    // result.bookmarkService,
    // result.profileService,
    // result.settingsService,
    // result.contactsService,
    // result.aboutService,
    // result.dappPermissionsService,
    // result.languageService,
    // # result.mnemonicService,
    // result.privacyService,
    // result.providerService,
    // result.stickersService,
    // result.activityCenterService,
    // result.savedAddressService,
    // result.nodeConfigurationService,
    // result.devicesService,
    // result.mailserversService

    // # Do connections
    doConnect();
}

AppController::~AppController()
{
    delete m_startupModule;
    delete m_accountsService;
}

void AppController::doConnect()
{
    // self.statusFoundation.status.events.once("nodeStopped") do(a: Args):
    // TODO: remove this once accounts are not tracked in the AccountsModel
    // self.statusFoundation.status.reset()
    QObject::connect(dynamic_cast<QObject*>(m_mainModulePtr), SIGNAL(loaded()), this, SLOT(mainDidLoad()));
}

void AppController::startupDidLoad()
{
    // singletonInstance.engine.setRootContextProperty("localAppSettings", self.localAppSettingsVariant)
    // singletonInstance.engine.setRootContextProperty("localAccountSettings", self.localAccountSettingsVariant)
    // singletonInstance.engine.load(newQUrl("qrc:///main.qml"))

    // We need to init a language service once qml is loaded
    // self.languageService.init()
}

void AppController::mainDidLoad()
{
    //self.statusFoundation.onLoggedIn()
    m_startupModule->moveToAppState();

    //self.mainModule.checkForStoringPassword()
}

void AppController::start()
{
    // self.ethService.init()
    m_accountsService->init();

    m_startupModule->load();
}

void AppController::load()
{
    qWarning() << "TODO: init services and load main module";
    m_walletServicePtr->init();
    // self.settingsService.init()
    // self.nodeConfigurationService.init()
    // self.contactsService.init()
    // self.chatService.init()
    // self.messageService.init()
    // self.communityService.init()
    // self.bookmarkService.init()
    // self.tokenService.init()
    // self.dappPermissionsService.init()
    // self.providerService.init()
    // self.walletAccountService.init()
    // self.transactionService.init()
    // self.stickersService.init()
    // self.networkService.init()
    // self.activityCenterService.init()
    // self.savedAddressService.init()
    // self.aboutService.init()
    // self.devicesService.init()
    // self.mailserversService.init()

    // let pubKey = self.settingsService.getPublicKey()
    // singletonInstance.localAccountSensitiveSettings.setFileName(pubKey)
    // singletonInstance.engine.setRootContextProperty("localAccountSensitiveSettings", self.localAccountSensitiveSettingsVariant)
    // singletonInstance.engine.setRootContextProperty("globalUtils", self.globalUtilsVariant)

    // # other global instances
    // self.buildAndRegisterLocalAccountSensitiveSettings()
    // self.buildAndRegisterUserProfile()

    // # load main module
    m_mainModulePtr->load(
        // self.statusFoundation.status.events,
        // self.settingsService,
        // self.contactsService,
        // self.chatService,
        // self.communityService,
        // self.messageService
    );
}

void AppController::userLoggedIn()
{
    //self.statusFoundation.status.startMessenger()
    AppController::load();

    // Once user is logged in and main module is loaded we need to check if it gets here importing mnemonic or not
    // and delete mnemonic in the first case.
    auto importedAccount = m_accountsService->getImportedAccount();
    if(importedAccount.isValid())
    {
        // self.privacyService.removeMnemonic();
    }
}

void AppController::buildAndRegisterLocalAccountSensitiveSettings()
{

    // var pubKey = self.settingsService.getPublicKey()
    // singletonInstance.localAccountSensitiveSettings.setFileName(pubKey)
    // singletonInstance.engine.setRootContextProperty("localAccountSensitiveSettings", self.localAccountSensitiveSettingsVariant)
}

void AppController::buildAndRegisterUserProfile()
{
    // let pubKey = self.settingsService.getPublicKey()
    // let preferredName = self.settingsService.getPreferredName()
    // let ensUsernames = self.settingsService.getEnsUsernames()
    // let firstEnsName = if (ensUsernames.len > 0): ensUsernames[0] else: ""
    // let sendUserStatus = self.settingsService.getSendStatusUpdates()
    // // This is still not in use. Read a comment in UserProfile.
    // // let currentUserStatus = self.settingsService.getCurrentUserStatus()

    // let loggedInAccount = self.accountsService.getLoggedInAccount()
    // var thumbnail, large: string
    // for img in loggedInAccount.images:
    // if(img.imgType == "large"):
    //     large = img.uri
    // elif(img.imgType == "thumbnail"):
    //     thumbnail = img.uri

    // let meAsContact = self.contactsService.getContactById(pubKey)

    // singletonInstance.userProfile.setFixedData(loggedInAccount.name, loggedInAccount.keyUid, loggedInAccount.identicon,
    // pubKey)
    // singletonInstance.userProfile.setPreferredName(preferredName)
    // singletonInstance.userProfile.setEnsName(meAsContact.name)
    // singletonInstance.userProfile.setFirstEnsName(firstEnsName)
    // singletonInstance.userProfile.setThumbnailImage(thumbnail)
    // singletonInstance.userProfile.setLargeImage(large)
    // singletonInstance.userProfile.setUserStatus(sendUserStatus)

    // singletonInstance.engine.setRootContextProperty("userProfile", self.userProfileVariant)
}
