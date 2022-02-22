#include <QDebug>
#include <QQmlContext>

#include "../shared/section_item.h"
#include "module.h"
#include "modules/main/wallet/module.h"
#include "singleton.h"

namespace Modules::Main
{
Module::Module(std::shared_ptr<Wallets::ServiceInterface> walletService, QObject* parent)
    : QObject(parent)
{
    m_controllerPtr = new Controller(this);
    m_viewPtr = new View(this);

    // Submodules
    m_walletModulePtr = new Modules::Main::Wallet::Module(walletService, this);

    m_moduleLoaded = false;
    connect();
}

void Module::connect()
{
    QObject::connect(m_viewPtr, &View::viewLoaded, this, &Module::viewDidLoad);
    // FIXME: use PointerToMember approach
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
