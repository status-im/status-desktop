#pragma once

#include <QtCore>

namespace Status::Modules::Startup::Login
{
    class Item
    {
    public:
        Item() {}
        Item(const QString& name, const QString& identicon, const QString& thumbnailImage, const QString& largeImage,
             const QString& keyUid);
        QString getName() const;
        QString getIdenticon() const;
        QString getThumbnailImage() const;
        QString getLargeImage() const;
        QString getKeyUid() const;

    private:
        QString m_name;
        QString m_identicon;
        QString m_thumbnailImage;
        QString m_largeImage;
        QString m_keyUid;
    };
}
