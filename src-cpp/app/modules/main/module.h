#pragma once

#include <QObject>
#include <QPointer>

#include "interfaces/module_access_interface.h"
#include "wallet_accounts/service_interface.h"

#include "controller.h"
#include "view.h"

namespace Modules::Main
{
class Module : public QObject, public IModuleAccess
{
    Q_OBJECT

public:
    explicit Module(std::shared_ptr<Wallets::ServiceInterface> walletService, QObject* parent = nullptr);

    void load() override;
    bool isLoaded() override;

public slots:
    void viewDidLoad();
    void walletDidLoad();

signals:
    void loaded() override;

private:
    void connect();
    void checkIfModuleDidLoad();

    // FIXME: don't use raw pointers
    // (should be either plain member, reference or smart pointer, depending on ownerhip)
    View* m_viewPtr;
    Controller* m_controllerPtr;
    Modules::Main::IModuleAccess* m_walletModulePtr;
    bool m_moduleLoaded;
};
} // namespace Modules::Main
