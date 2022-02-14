#include <QDebug>
#include <QQmlContext>

#include "module.h"
#include "singleton.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
namespace Accounts
{
Module::Module(std::shared_ptr<Wallets::ServiceInterface> walletsService)
{
    m_controllerPtr = std::make_unique<Controller>(walletsService);
    m_viewPtr = std::make_unique<View>();

    m_moduleLoaded = false;

    connect();
}

void Module::connect()
{
    QObject::connect(m_viewPtr.get(), &View::viewLoaded, this, &Module::viewDidLoad);
}

void Module::load()
{
    Global::Singleton::instance()->engine()->rootContext()->setContextProperty("walletSectionAccounts", m_viewPtr.get());
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
            items << Item(acc.name, acc.address, acc.path, acc.color, acc.publicKey, acc.walletType, acc.isWallet, acc.isChat, 0);
        }

        m_viewPtr->setModelItems(items);
    }
    else
    {
        qWarning()<<"No accounts found!";
    }
}

} // namespace Accounts
} // namespace Main
} // namespace Wallet
} // namespace Modules
