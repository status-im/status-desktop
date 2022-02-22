#pragma once

#include <QObject>

#include "../modules/main/interfaces/module_access_interface.h"
#include "../modules/startup/module_access_interface.h"
#include "accounts/service.h"
#include "app_controller_delegate.h"
#include "app_service.h"
#include "wallet_accounts/service.h"

class AppController : public QObject, AppControllerDelegate
{
    Q_OBJECT
    //statusFoundation: StatusFoundation

    // Global
    //localAppSettingsVariant: QVariant
    //localAccountSettingsVariant: QVariant
    //localAccountSensitiveSettingsVariant: QVariant
    //userProfileVariant: QVariant
    //globalUtilsVariant: QVariant

    // Services
    // FIXME: don't use raw pointers
    Accounts::Service* m_accountsService;
    std::shared_ptr<Wallets::Service> m_walletServicePtr;

    // Modules
    // To-Do make this a shared pointer and remove circular dependency.
    Modules::Startup::ModuleAccessInterface* m_startupModule;
    Modules::Main::IModuleAccess* m_mainModulePtr;

public:
    AppController();
    ~AppController() override;
    void start();

public slots:
    void mainDidLoad();

private:
    void connect();
    void startupDidLoad() override;
    void load();
    void userLoggedIn() override;
    void buildAndRegisterLocalAccountSensitiveSettings();
    void buildAndRegisterUserProfile();
};
