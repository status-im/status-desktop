#pragma once

#include "accounts/account.h"
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
namespace Login
{
class Controller : public QObject, ControllerInterface
{
    Q_OBJECT

public:
    Controller(ModuleControllerDelegateInterface* delegate,
               // keychainService,
               Accounts::ServiceInterface* accountsService,
               QObject* parent = nullptr);
    void init() override;
    QVector<Accounts::AccountDto> getOpenedAccounts() override;
    Accounts::AccountDto getSelectedAccount();
    void setSelectedAccountKeyUid(QString keyUid) override;
    void login(QString password) override;
    void onLogin(Signals::NodeSignal signal);

private:
    // Keychain::m_keychainService
    Accounts::ServiceInterface* m_accountsService;
    ModuleControllerDelegateInterface* m_delegate;
    QString m_selectedAccountKeyUid;
};
} // namespace Login
} // namespace Startup
} // namespace Modules
