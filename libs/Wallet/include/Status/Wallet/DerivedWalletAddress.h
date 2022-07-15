#pragma once

#include <StatusGo/Wallet/DerivedAddress.h>

#include <QObject>

namespace GoWallet = Status::StatusGo::Wallet;

namespace Status::Wallet {

class DerivedWalletAddress : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString address READ address CONSTANT)
    Q_PROPERTY(bool alreadyCreated READ alreadyCreated CONSTANT)

public:
    explicit DerivedWalletAddress(GoWallet::DerivedAddress address, QObject *parent = nullptr);

    QString address() const;

    const GoWallet::DerivedAddress &data() const { return m_derivedAddress; };

    bool alreadyCreated() const;

private:
    const GoWallet::DerivedAddress m_derivedAddress;
};

using DerivedWalletAddressPtr = std::shared_ptr<DerivedWalletAddress>;

}
