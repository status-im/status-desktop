#ifndef WALLET_ACCOUNT_MODULE_H
#define WALLET_ACCOUNT_MODULE_H

#include <QObject>

#include "wallet_accounts/service_interface.h"
#include "interfaces/module_access_interface.h"
#include "controller.h"
#include "view.h"

namespace Modules::Main::Wallet::Accounts
{
class Module : public QObject, virtual public IModuleAccess
{
    Q_OBJECT
    Q_INTERFACES(Modules::Main::IModuleAccess)

private:
    View* m_viewPtr;
    Controller* m_controllerPtr;

    bool m_moduleLoaded;

    void connect();
    void refreshWalletAccounts();
public:
    explicit Module(std::shared_ptr<Wallets::ServiceInterface> walletsService, QObject* parent);
    ~Module() = default;

    void load() override;
    bool isLoaded() override;

public slots:
    void viewDidLoad();

signals:
    void loaded() override;
};
} // namespace Modules::Main::Wallet::Accounts

#endif // WALLET_ACCOUNT_MODULE_H
