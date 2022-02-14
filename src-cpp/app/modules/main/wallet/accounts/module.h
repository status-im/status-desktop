#ifndef WALLET_ACCOUNT_MODULE_H
#define WALLET_ACCOUNT_MODULE_H

#include <QObject>

#include "wallet_accounts/service_interface.h"
#include "interfaces/module_access_interface.h"
#include "controller.h"
#include "view.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
namespace Accounts
{
class Module : public QObject, virtual public IWalletAccountsModuleAccess
{
    Q_OBJECT
private:
    std::unique_ptr<View> m_viewPtr;
    std::unique_ptr<Controller> m_controllerPtr;

    bool m_moduleLoaded;

    void connect();
    void refreshWalletAccounts();
public:
    explicit Module(std::shared_ptr<Wallets::ServiceInterface> walletsService);
    ~Module() = default;

    void load() override;
    bool isLoaded() override;

public slots:
    void viewDidLoad();

signals:
    void loaded() override;
};
}; // namespace Accounts
}; // namespace Wallet
}; // namespace Main
}; // namespace Modules

#endif // WALLET_ACCOUNT_MODULE_H
