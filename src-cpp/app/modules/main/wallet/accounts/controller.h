#pragma once

#include <QObject>

#include "interfaces/controller_interface.h"
#include "signals.h"
#include "wallet_accounts/service_interface.h"
#include "wallet_accounts/wallet_account.h"

namespace Modules::Main::Wallet::Accounts
{
class Controller : public QObject, public IController
{
    Q_OBJECT

public:
    explicit Controller(std::shared_ptr<Wallets::ServiceInterface> walletService, QObject* parent = nullptr);

    void init() override;

    QList<Wallets::WalletAccountDto> getWalletAccounts();
    QString generateNewAccount(const QString& password, const QString& accountName, const QString& color);
    QString addAccountsFromPrivateKey(const QString& privateKey,
                                      const QString& password,
                                      const QString& accountName,
                                      const QString& color);
    QString addAccountsFromSeed(const QString& seedPhrase,
                                const QString& password,
                                const QString& accountName,
                                const QString& color);
    QString addWatchOnlyAccount(const QString& address, const QString& accountName, const QString& color);
    void deleteAccount(const QString& address);

private:
    std::shared_ptr<Wallets::ServiceInterface> m_walletServicePtr;
};
} // namespace Modules::Main::Wallet::Accounts
