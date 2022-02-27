#include "Item.h"

using namespace Status::Modules::Startup::Onboarding;

Item::Item(const QString& id, const QString& alias, const QString& identicon, const QString& address,
           const QString& keyUid)
    : m_id(id)
    , m_alias(alias)
    , m_identicon(identicon)
    , m_address(address)
    , m_keyUid(keyUid)
{
}

QString Item::getId() const
{
    return m_id;
}

QString Item::getAlias() const
{
    return m_alias;
}

QString Item::getIdenticon() const
{
    return m_identicon;
}

QString Item::getAddress() const
{
    return m_address;
}

QString Item::getKeyUid() const
{
    return m_keyUid;
}
