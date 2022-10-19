#pragma once

#include <StatusGo/Wallet/DerivedAddress.h>

#include <QtQmlIntegration>

namespace WalletGo = Status::StatusGo::Wallet;

namespace Status::Wallet
{

class DerivedWalletAddress : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("C++ only")

    Q_PROPERTY(QString address READ address CONSTANT)
    Q_PROPERTY(bool alreadyCreated READ alreadyCreated CONSTANT)

public:
    explicit DerivedWalletAddress(WalletGo::DerivedAddress address, QObject* parent = nullptr);

    QString address() const;

    const WalletGo::DerivedAddress& data() const
    {
        return m_derivedAddress;
    };

    bool alreadyCreated() const;

private:
    const WalletGo::DerivedAddress m_derivedAddress;
};

using DerivedWalletAddressPtr = std::shared_ptr<DerivedWalletAddress>;

} // namespace Status::Wallet
