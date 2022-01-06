#include "item.h"
#include <QString>

namespace Modules
{
namespace Startup
{
namespace Login
{
Item::Item() { }

Item::Item(QString name, QString identicon, QString thumbnailImage, QString largeImage, QString keyUid)
	: m_name(name)
	, m_identicon(identicon)
	, m_thumbnailImage(thumbnailImage)
	, m_largeImage(largeImage)
	, m_keyUid(keyUid)
{ }
QString Item::getName()
{
	return m_name;
}
QString Item::getIdenticon()
{
	return m_identicon;
}
QString Item::getThumbnailImage()
{
	return m_thumbnailImage;
}
QString Item::getLargeImage()
{
	return m_largeImage;
}
QString Item::getKeyUid()
{
	return m_keyUid;
}
} // namespace Login
} // namespace Startup
} // namespace Modules