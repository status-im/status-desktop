#ifndef WALLET_ACCOUNT_MODULE_H
#define WALLET_ACCOUNT_MODULE_H

#include <QObject>

#include "controller.h"
#include "interfaces/module_access_interface.h"
#include "view.h"
#include "wallet_accounts/service_interface.h"

namespace Modules::Main::Wallet::Accounts
{
class Module : public QObject, virtual public IModuleAccess
{
    Q_OBJECT
    Q_INTERFACES(Modules::Main::IModuleAccess)
public:
    explicit Module(std::shared_ptr<Wallets::ServiceInterface> walletsService, QObject* parent);
    ~Module() = default;

    void load() override;
    bool isLoaded() override;

public slots:
    void viewDidLoad();

signals:
    void loaded() override;

private:
    void connect();

private:
    View* m_viewPtr;
    Controller* m_controllerPtr;

    bool m_moduleLoaded;
};
} // namespace Modules::Main::Wallet::Accounts

#endif // WALLET_ACCOUNT_MODULE_H
