#include <QDebug>
#include <QQmlContext>

#include "module.h"
#include "singleton.h"
#include "accounts/module.h"

namespace Modules::Main::Wallet
{
Module::Module(std::shared_ptr<Wallets::ServiceInterface> walletsService, QObject *parent): QObject(parent)
{
    m_controllerPtr = new Controller(walletsService, this);
    m_viewPtr = new View(this);

    // Sub-Modules
    m_accountsModulePtr = new Modules::Main::Wallet::Accounts::Module(walletsService, this);

    m_moduleLoaded = false;
    connect();
}

void Module::connect()
{
    QObject::connect(m_viewPtr, SIGNAL(viewLoaded()), this, SLOT(viewDidLoad()));
    QObject::connect(dynamic_cast<QObject*>(m_accountsModulePtr), SIGNAL(loaded()), this, SLOT(accountsDidLoad()));
}

void Module::load()
{
    Global::Singleton::instance()->engine()->rootContext()->setContextProperty("walletSection", m_viewPtr);
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

} // namespace Modules::Main::Wallet
