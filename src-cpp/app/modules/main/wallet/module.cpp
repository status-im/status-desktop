#include <QDebug>
#include <QQmlContext>

#include "module.h"
#include "singleton.h"
#include "accounts/module.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
Module::Module(std::shared_ptr<Wallets::ServiceInterface> walletsService)
{
    m_controllerPtr = std::make_unique<Controller>(walletsService);
    m_viewPtr = std::make_unique<View>();

    // Sub-Modules
    m_accountsModulePtr = std::make_unique<Modules::Main::Wallet::Accounts::Module>(walletsService);

    m_moduleLoaded = false;
    connect();
}

void Module::connect()
{
    QObject::connect(m_viewPtr.get(), SIGNAL(viewLoaded()), this, SLOT(viewDidLoad()));
    QObject::connect(dynamic_cast<QObject*>(m_accountsModulePtr.get()), SIGNAL(loaded()), this, SLOT(accountsDidLoad()));
}

void Module::load()
{
    Global::Singleton::instance()->engine()->rootContext()->setContextProperty("walletSection", m_viewPtr.get());
    m_controllerPtr->init();
    m_viewPtr->load();
    m_accountsModulePtr->load();
}

bool Module::isLoaded()
{
    return m_moduleLoaded;
}

void Module::checkIfModuleDidLoad()
{
    if(!m_accountsModulePtr->isLoaded())
    {
        return;
    }
    m_moduleLoaded = true;
    emit loaded();
}

void Module::viewDidLoad()
{   
    checkIfModuleDidLoad();
}

void Module::accountsDidLoad()
{
    checkIfModuleDidLoad();
}

} // namespace Main
} // namespace Wallet
} // namespace Modules
