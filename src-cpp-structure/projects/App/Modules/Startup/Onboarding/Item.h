#pragma once

#include <QtCore>

namespace Status::Modules::Startup::Onboarding
{
    class Item
    {
    public:
        Item(const QString& id, const QString& alias, const QString& identicon, const QString& address,
             const QString& keyUid);

        QString getId() const;
        QString getAlias() const;
        QString getIdenticon() const;
        QString getAddress() const;
        QString getKeyUid() const;

    private:
        QString m_id;
        QString m_alias;
        QString m_identicon;
        QString m_address;
        QString m_keyUid;
    };
}
