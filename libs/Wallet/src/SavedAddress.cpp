#include "Status/Wallet/SavedAddress.h"

namespace Status::Wallet
{

SavedAddress::SavedAddress(const QString& address, const QString& name, QObject* parent)
    : QObject(parent)
    , m_address(address)
    , m_name(name)
{ }

const QString& SavedAddress::address() const
{
    return m_address;
}

const QString& SavedAddress::name() const
{
    return m_name;
}

} // namespace Status::Wallet
