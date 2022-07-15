#pragma once

#include "Accounts/ChatOrWalletAccount.h"

#include <QObject>

namespace GoAccounts = Status::StatusGo::Accounts;

namespace Status::Wallet {

class WalletAccount: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString address READ address CONSTANT)
    Q_PROPERTY(QColor color READ color CONSTANT)

public:
    explicit WalletAccount(const GoAccounts::ChatOrWalletAccount rawAccount, QObject *parent = nullptr);

    const QString &name() const;

    const QString &address() const;

    QColor color() const;

    const GoAccounts::ChatOrWalletAccount &data() const { return m_data; };

private:
    const GoAccounts::ChatOrWalletAccount m_data;
};

using WalletAccountPtr = std::shared_ptr<WalletAccount>;
using WalletAccounts = std::vector<WalletAccount>;

}
