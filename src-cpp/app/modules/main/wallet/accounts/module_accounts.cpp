#include <QDebug>
#include <QQmlContext>

#include "module_accounts.h"
#include "singleton.h"

namespace Modules::Main::Wallet::Accounts
{
Module::Module(std::shared_ptr<Wallets::ServiceInterface> walletsService, QObject* parent)
    : QObject(parent)
{
    m_controllerPtr = new Controller(walletsService, this);
    m_viewPtr = new View(this);

    m_moduleLoaded = false;

    doConnect();
}

void Module::doConnect()
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
    refreshWalletAccounts();
    m_moduleLoaded = true;
    emit loaded();
}

void Module::refreshWalletAccounts()
{
    auto walletAccounts = m_controllerPtr->getWalletAccounts();

    if(walletAccounts.size() > 0)
    {
        QVector<Item> items;
        foreach(const auto& acc, walletAccounts)
        {
            items << Item(
                acc.name, acc.address, acc.path, acc.color, acc.publicKey, acc.walletType, acc.isWallet, acc.isChat, 0);
        }

        m_viewPtr->setModelItems(items);
    }
    else
    {
        qWarning() << "No accounts found!";
    }
}
} // namespace Modules::Main::Wallet::Accounts
