#include <QDebug>

#include "view.h"

namespace Modules::Main::Wallet::Accounts
{
View::View(Controller *controller, QObject* parent)
    : QObject(parent),
      m_controllerPtr(controller)
{
    m_modelPtr = new Model(this);
    m_currentAccountPtr = new Item(this);
}

void View::load()
{
    refreshWalletAccounts();
    emit viewLoaded();
}

Model* View::getModel() const
{
    return m_modelPtr;
}

void View::setModelItems(const QVector<Item*>& accounts) {
    m_modelPtr->setItems(accounts);
    m_currentAccountPtr->setData(accounts.at(0));
    modelChanged();
}

void View::refreshWalletAccounts()
{
    auto walletAccounts = m_controllerPtr->getWalletAccounts();

    if(walletAccounts.size() > 0)
    {
        QVector<Item*> items;
        foreach(const auto& acc, walletAccounts)
        {
            items << new Item(this, acc.name, acc.address, acc.path, acc.color, acc.publicKey, acc.walletType, acc.isWallet, acc.isChat, 0);
        }
        setModelItems(items);
    }
    else
    {
        qWarning()<<"No accounts found!";
    }
}

QString View::generateNewAccount(const QString& password, const QString& accountName, const QString& color)
{
    QString error = "";
    if(m_controllerPtr)
    {
        error = m_controllerPtr->generateNewAccount(password, accountName, color);
        if(error.isEmpty())
        {
            refreshWalletAccounts();
        }
    }
    else {
        error = "controller pointer is null";
    }
    return error;
}

QString View::addAccountsFromPrivateKey(const QString& privateKey, const QString& password, const QString& accountName, const QString& color)
{
    QString error = "";
    if(m_controllerPtr)
    {
        error = m_controllerPtr->addAccountsFromPrivateKey(privateKey, password, accountName, color);
        if(error.isEmpty())
        {
            refreshWalletAccounts();
        }
    }
    else {
        error = "controller pointer is null";
    }
    return error;
}

QString View::addAccountsFromSeed(const QString& seedPhrase, const QString& password, const QString& accountName, const QString& color)
{
    QString error = "";
    if(m_controllerPtr)
    {
        error = m_controllerPtr->addAccountsFromSeed(seedPhrase, password, accountName, color);
        if(error.isEmpty())
        {
            refreshWalletAccounts();
        }
    }
    else {
        error = "controller pointer is null";
    }
    return error;
}

QString View::addWatchOnlyAccount(const QString& address, const QString& accountName , const QString& color)
{
    QString error = "";
    if(m_controllerPtr)
    {
        error = m_controllerPtr->addWatchOnlyAccount(address, accountName, color);
        if(error.isEmpty())
        {
            refreshWalletAccounts();
        }
    }
    else {
        error = "controller pointer is null";
    }
    return error;
}

void View::deleteAccount(const QString& address)
{
    if(m_controllerPtr)
    {
        m_controllerPtr->deleteAccount(address);
        refreshWalletAccounts();
    }
    else {
        qWarning()<<"controller pointer is null";
    }
}

void View::switchAccount(int index)
{
    auto itemAtIndex = m_modelPtr->getItemByIndex(index);
    if(itemAtIndex)
    {
        m_currentAccountPtr->setData(itemAtIndex);
        emit currentAccountChanged();
    }
}

Item* View::getCurrentAccount() const
{
    return m_currentAccountPtr;
}

} // namespace Modules::Main::Wallet::Accounts
