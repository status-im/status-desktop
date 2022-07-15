#include "DerivedWalletAddress.h"

namespace Status::Wallet {

DerivedWalletAddress::DerivedWalletAddress(GoWallet::DerivedAddress address, QObject *parent)
    : QObject{parent}
    , m_derivedAddress{std::move(address)}
{
}

QString DerivedWalletAddress::address() const
{
    return m_derivedAddress.address.get();
}

bool DerivedWalletAddress::alreadyCreated() const
{
    return m_derivedAddress.alreadyCreated;
}

}
