#pragma once

#include <StatusGo/Wallet/BigInt.h>
#include <StatusGo/Wallet/Token.h>

#include <QtQmlIntegration>

namespace WalletGo = Status::StatusGo::Wallet;

namespace Status::Wallet
{

class WalletAsset : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("C++ only, for now")

    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString symbol READ symbol CONSTANT)
    Q_PROPERTY(QColor color READ color CONSTANT)
    Q_PROPERTY(quint64 count READ count CONSTANT)
    Q_PROPERTY(float value READ value CONSTANT)

public:
    explicit WalletAsset(const WalletGo::TokenPtr token, StatusGo::Wallet::BigInt balance, QObject* parent = nullptr);

    const QString name() const;

    const QString symbol() const;

    const QColor color() const;

    quint64 count() const;

    float value() const;

private:
    const WalletGo::TokenPtr m_token;
    // const GoWallet::NativeToken m_nativeToken;

    StatusGo::Wallet::BigInt m_balance;
    int m_count;
};

} // namespace Status::Wallet
