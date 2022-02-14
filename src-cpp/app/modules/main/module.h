#ifndef MODULE_H
#define MODULE_H

#include <QObject>
#include <QPointer>

#include "interfaces/module_access_interface.h"
#include "wallet_accounts/service_interface.h"
#include "wallet/interfaces/module_access_interface.h"

#include "controller.h"
#include "view.h"

namespace Modules
{
namespace Main
{
class Module : public QObject, virtual public IModuleAccess
{
    Q_OBJECT
private:
    bool m_moduleLoaded;

    std::unique_ptr<View> m_viewPtr;
    std::unique_ptr<Controller> m_controllerPtr;
    std::unique_ptr<Modules::Main::Wallet::IWalletModuleAccess> m_walletModulePtr;

    void connect();

public:
    explicit Module(std::shared_ptr<Wallets::ServiceInterface> walletService);
    ~Module() = default;

    void load() override;
    bool isLoaded() override;
    void checkIfModuleDidLoad();

public slots:
    void viewDidLoad();
    void walletDidLoad();

signals:
    void loaded() override;
};
}; // namespace Main
}; // namespace Modules

#endif // MODULE_H
