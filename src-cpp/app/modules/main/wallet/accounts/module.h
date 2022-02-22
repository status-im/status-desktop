#pragma once

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
public:
    explicit Module(std::shared_ptr<Wallets::ServiceInterface> walletsService, QObject* parent = nullptr);

    void load() override;
    bool isLoaded() override;

public slots:
    void viewDidLoad();

signals:
    void loaded() override;

private:
    void connect();

    View* m_viewPtr;
    Controller* m_controllerPtr;

    bool m_moduleLoaded;
};
} // namespace Modules::Main::Wallet::Accounts
