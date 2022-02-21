#ifndef WALLET_MODULE_H
#define WALLET_MODULE_H

#include <QObject>

#include "wallet_accounts/service_interface.h"

#include "../interfaces/module_access_interface.h"
#include "controller.h"
#include "view.h"

namespace Modules::Main::Wallet
{
class Module : public QObject, virtual public IModuleAccess
{
    Q_OBJECT
    Q_INTERFACES(Modules::Main::IModuleAccess)

private:
    View* m_viewPtr;
    Controller* m_controllerPtr;
    IModuleAccess* m_accountsModulePtr;

    bool m_moduleLoaded;

    void connect();

public:
    explicit Module(std::shared_ptr<Wallets::ServiceInterface> walletsService, QObject* parent);
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
} // namespace Modules::Main::Wallet

#endif // WALLET_MODULE_H
