#pragma once

#include <QObject>
#include <memory>

#include "controller.h"
#include "item.h"
#include "model.h"

namespace Modules::Main::Wallet::Accounts
{
class View : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Model* model READ getModel NOTIFY modelChanged)
    Q_PROPERTY(Item* currentAccount READ getCurrentAccount NOTIFY currentAccountChanged)

public:
    explicit View(Controller* controller, QObject* parent = nullptr);

    void load();
    void setModelItems(const QVector<Item*>& accounts);
    Model* getModel() const;
    Item* getCurrentAccount() const;

    Q_INVOKABLE QString generateNewAccount(const QString& password, const QString& accountName, const QString& color);
    Q_INVOKABLE QString addAccountsFromPrivateKey(const QString& privateKey,
                                                  const QString& password,
                                                  const QString& accountName,
                                                  const QString& color);
    Q_INVOKABLE QString addAccountsFromSeed(const QString& seedPhrase,
                                            const QString& password,
                                            const QString& accountName,
                                            const QString& color);
    Q_INVOKABLE QString addWatchOnlyAccount(const QString& address, const QString& accountName, const QString& color);
    Q_INVOKABLE void deleteAccount(const QString& address);
    Q_INVOKABLE void switchAccount(int index);

signals:
    void viewLoaded();
    void modelChanged();
    void currentAccountChanged();

private:
    void refreshWalletAccounts();

    Model* m_modelPtr;
    Controller* m_controllerPtr;
    Item* m_currentAccountPtr;
};
} // namespace Modules::Main::Wallet::Accounts
