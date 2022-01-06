#pragma once

#include <QString>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
class Item
{
private:
	QString m_id;
	QString m_alias;
	QString m_identicon;
	QString m_address;
	QString m_keyUid;

public:
	Item(QString id, QString alias, QString identicon, QString address, QString keyUid);
	QString getId();
	QString getAlias();
	QString getIdenticon();
	QString getAddress();
	QString getKeyUid();
};
} // namespace Onboarding
} // namespace Startup
} // namespace Modules
