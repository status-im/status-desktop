#pragma once

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

public:
    explicit Module(std::shared_ptr<Wallets::ServiceInterface> walletsService, QObject* parent);

    void load() override;
    bool isLoaded() override;

    void checkIfModuleDidLoad();

public slots:
    void viewDidLoad();
    void accountsDidLoad();

signals:
    void loaded() override;

private:
    void connect();

    View* m_viewPtr;
    Controller* m_controllerPtr;
    IModuleAccess* m_accountsModulePtr;
    bool m_moduleLoaded;
};
} // namespace Modules::Main::Wallet
