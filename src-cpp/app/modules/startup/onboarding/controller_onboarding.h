#pragma once

#include "accounts/generated_account.h"
#include "accounts/service_interface.h"
#include "controller_interface.h"
#include "interfaces/module_controller_delegate_interface.h"
#include "signals.h"
#include <QObject>
#include <QString>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
class Controller : public QObject, ControllerInterface
{
    Q_OBJECT

public:
    Controller(ModuleControllerDelegateInterface* delegate,
               Accounts::ServiceInterface* accountsService,
               QObject* parent = nullptr);
    void init() override;
    QVector<Accounts::GeneratedAccountDto> getGeneratedAccounts() override;
    Accounts::GeneratedAccountDto getImportedAccount() override;
    void setSelectedAccountByIndex(int index) override;
    void storeSelectedAccountAndLogin(QString password) override;
    QString validateMnemonic(QString mnemonic) override;
    void importMnemonic(QString mnemonic) override;
    void onLogin(Signals::NodeSignal signal);

private:
    Accounts::ServiceInterface* m_accountsService;
    ModuleControllerDelegateInterface* m_delegate;
    QString m_selectedAccountId;
};
} // namespace Onboarding
} // namespace Startup
} // namespace Modules
