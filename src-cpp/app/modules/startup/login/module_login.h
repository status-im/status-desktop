#pragma once

#include "../interfaces/module_login_delegate_interface.h"
#include "accounts/generated_account.h"
#include "accounts/service_interface.h"
#include "controller_login.h"
#include "interfaces/module_controller_delegate_interface.h"
#include "interfaces/module_view_delegate_interface.h"
#include "item_login.h"
#include "module_access_interface.h"
#include "view_login.h"
#include <QVariant>

namespace Modules
{
namespace Startup
{
namespace Login
{
class Module : public ModuleAccessInterface, ModuleControllerDelegateInterface, ModuleViewDelegateInterface
{
private:
    Modules::Startup::ModuleLoginDelegateInterface* m_delegate;
    View* m_view;
    Controller* m_controller;
    bool m_moduleLoaded;

public:
    Module(Modules::Startup::ModuleLoginDelegateInterface* delegate,
           // keychainService
           Accounts::ServiceInterface* accountsService);
    ~Module();
    void extractImages(Accounts::AccountDto account, QString& thumbnailImage, QString& largeImage);
    void load() override;
    bool isLoaded() override;
    void viewDidLoad() override;
    void setSelectedAccount(Item item) override;
    void login(QString password) override;
    void setupAccountError();
    void emitAccountLoginError(QString error) override;
    void emitObtainingPasswordError(QString errorDescription) override;
    void emitObtainingPasswordSuccess(QString password) override;
};
}; // namespace Login
}; // namespace Startup
}; // namespace Modules
