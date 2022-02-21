#include <QDebug>
#include <QQmlContext>

#include "module.h"
#include "singleton.h"

namespace Modules::Main::Wallet::Accounts
{
Module::Module(std::shared_ptr<Wallets::ServiceInterface> walletsService, QObject* parent)
    : QObject(parent)
{
    m_controllerPtr = new Controller(walletsService, this);
    m_viewPtr = new View(m_controllerPtr, this);

    m_moduleLoaded = false;

    connect();
}

void Module::connect()
{
    QObject::connect(m_viewPtr, &View::viewLoaded, this, &Module::viewDidLoad);
}

void Module::load()
{
    Global::Singleton::instance()->engine()->rootContext()->setContextProperty("walletSectionAccounts", m_viewPtr);
    m_controllerPtr->init();
    m_viewPtr->load();
}

bool Module::isLoaded()
{
    return m_moduleLoaded;
}

void Module::viewDidLoad()
{
    m_moduleLoaded = true;
    emit loaded();
}

} // namespace Modules::Main::Wallet::Accounts
