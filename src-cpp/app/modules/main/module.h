#ifndef MODULE_H
#define MODULE_H

#include <QObject>
#include <QPointer>

#include "interfaces/module_access_interface.h"
#include "wallet_accounts/service_interface.h"

#include "controller.h"
#include "view.h"

namespace Modules::Main
{
class Module : public QObject, virtual public IModuleAccess
{
    Q_OBJECT
    Q_INTERFACES(Modules::Main::IModuleAccess)

public:
    explicit Module(std::shared_ptr<Wallets::ServiceInterface> walletService, QObject* parent = nullptr);
    ~Module() = default;

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

private:
    View* m_viewPtr;
    Controller* m_controllerPtr;
    Modules::Main::IModuleAccess* m_walletModulePtr;
    bool m_moduleLoaded;

};
} // namespace Modules::Main

#endif // MODULE_H
