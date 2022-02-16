#include <QDebug>
#include <QQmlContext>

#include "module.h"
#include "singleton.h"
#include "modules/main/wallet/module.h"
#include "../shared/section_item.h"

namespace Modules::Main
{
Module::Module(std::shared_ptr<Wallets::ServiceInterface> walletsService, QObject* parent): QObject(parent)
{
    m_controllerPtr = new Controller(this);
    m_viewPtr = new View(this);

    // Submodules
    m_walletModulePtr = new Modules::Main::Wallet::Module(walletsService, this);

    m_moduleLoaded = false;
    connect();
}

void Module::connect()
{
    QObject::connect(m_viewPtr, &View::viewLoaded, this, &Module::viewDidLoad);
    QObject::connect(dynamic_cast<QObject*>(m_walletModulePtr), SIGNAL(loaded()), this, SLOT(walletDidLoad()));
}

void Module::load()
{
    Global::Singleton::instance()->engine()->rootContext()->setContextProperty("mainModule", m_viewPtr);
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

} // namespace Modules::Main
