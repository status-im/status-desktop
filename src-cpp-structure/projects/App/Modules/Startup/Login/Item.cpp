#include "Item.h"

using namespace Status::Modules::Startup::Login;

Item::Item(const QString& name, const QString& identicon, const QString& thumbnailImage, const QString& largeImage,
           const QString& keyUid)
    : m_name(name)
    , m_identicon(identicon)
    , m_thumbnailImage(thumbnailImage)
    , m_largeImage(largeImage)
    , m_keyUid(keyUid)
{
}

QString Item::getName() const
{
    return m_name;
}
QString Item::getIdenticon() const
{
    return m_identicon;
}
QString Item::getThumbnailImage() const
{
    return m_thumbnailImage;
}
QString Item::getLargeImage() const
{
    return m_largeImage;
}
QString Item::getKeyUid() const
{
    return m_keyUid;
}
