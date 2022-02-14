#ifndef WALLET_MODULE_H
#define WALLET_MODULE_H

#include <QObject>

#include "wallet_accounts/service_interface.h"
#include "interfaces/module_access_interface.h"
#include "accounts/interfaces/module_access_interface.h"
#include "controller.h"
#include "view.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
class Module : public QObject, virtual public IWalletModuleAccess
{
    Q_OBJECT
private:
    std::unique_ptr<View> m_viewPtr;
    std::unique_ptr<Controller> m_controllerPtr;
    std::unique_ptr<IWalletAccountsModuleAccess> m_accountsModulePtr;

    bool m_moduleLoaded;

    void connect();
public:
    explicit Module(std::shared_ptr<Wallets::ServiceInterface> walletsService);
    ~Module() = default;

    void load() override;
    bool isLoaded() override;

    void checkIfModuleDidLoad();
public slots:
    void viewDidLoad();
    void accountsDidLoad();
signals:
    void loaded() override;
};
}; // namespace Wallet
}; // namespace Main
}; // namespace Modules

#endif // WALLET_MODULE_H
