#pragma once

#include <QString>

namespace Modules
{
namespace Startup
{
namespace Login
{
class Item
{
private:
	QString m_name;
	QString m_identicon;
	QString m_thumbnailImage;
	QString m_largeImage;
	QString m_keyUid;

public:
	Item();
	Item(QString name, QString identicon, QString thumbnailImage, QString largeImage, QString keyUid);
	QString getName();
	QString getIdenticon();
	QString getThumbnailImage();
	QString getLargeImage();
	QString getKeyUid();
};
} // namespace Login
} // namespace Startup
} // namespace Modules
