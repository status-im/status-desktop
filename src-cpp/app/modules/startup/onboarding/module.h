#pragma once

#include "../interfaces/module_onboarding_delegate_interface.h"
#include "accounts/generated_account.h"
#include "accounts/service_interface.h"
#include "controller.h"
#include "interfaces/module_controller_delegate_interface.h"
#include "interfaces/module_view_delegate_interface.h"
#include "module_access_interface.h"
#include "view.h"
#include <QVariant>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
class Module : public ModuleAccessInterface, ModuleControllerDelegateInterface, ModuleViewDelegateInterface
{
private:
    Modules::Startup::ModuleOnboardingDelegateInterface* m_delegate;
    View* m_view;
    Controller* m_controller;
    bool m_moduleLoaded;

public:
    Module(Modules::Startup::ModuleOnboardingDelegateInterface* delegate, Accounts::ServiceInterface* accountsService);
    ~Module();
    void load() override;
    bool isLoaded() override;
    void viewDidLoad() override;
    void setSelectedAccountByIndex(int index) override;
    void storeSelectedAccountAndLogin(QString password) override;
    void setupAccountError() override;
    Accounts::GeneratedAccountDto getImportedAccount() override;
    QString validateMnemonic(QString mnemonic) override;
    void importMnemonic(QString mnemonic) override;
    void importAccountError() override;
    void importAccountSuccess() override;
};
}; // namespace Onboarding
}; // namespace Startup
}; // namespace Modules
