#include <QDebug>
#include <QQmlContext>

#include "module.h"
#include "singleton.h"
#include "modules/main/wallet/module.h"

namespace Modules
{
namespace Main
{
Module::Module(std::shared_ptr<Wallets::ServiceInterface> walletsService)
{
    m_controllerPtr = std::make_unique<Controller>();
    m_viewPtr = std::make_unique<View>();

    // Submodules
    m_walletModulePtr = std::make_unique<Modules::Main::Wallet::Module>(walletsService);

    m_moduleLoaded = false;
    connect();
}

void Module::connect()
{
    QObject::connect(m_viewPtr.get(), &View::viewLoaded, this, &Module::viewDidLoad);
    QObject::connect(dynamic_cast<QObject*>(m_walletModulePtr.get()), SIGNAL(loaded()), this, SLOT(walletDidLoad()));
}

void Module::load()
{
    Global::Singleton::instance()->engine()->rootContext()->setContextProperty("mainModule", m_viewPtr.get());
    m_controllerPtr->init();
    m_viewPtr->load();

    m_walletModulePtr->load();
}

void Module::checkIfModuleDidLoad()
{
    if(!m_walletModulePtr->isLoaded())
    {
        return;
    }
    m_moduleLoaded = true;
    emit loaded();
}

void Module::viewDidLoad()
{
    Module::checkIfModuleDidLoad();
}

void Module::walletDidLoad()
{
    Module::checkIfModuleDidLoad();
}

bool Module::isLoaded()
{
    return m_moduleLoaded;
}

} // namespace Main
} // namespace Modules
