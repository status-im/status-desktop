#include "item.h"
#include <QString>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
Item::Item(QString id, QString alias, QString identicon, QString address, QString keyUid)
	: m_id(id)
	, m_alias(alias)
	, m_identicon(identicon)
	, m_address(address)
	, m_keyUid(keyUid)
{ }
QString Item::getId()
{
	return m_id;
}
QString Item::getAlias()
{
	return m_alias;
}
QString Item::getIdenticon()
{
	return m_identicon;
}
QString Item::getAddress()
{
	return m_address;
}
QString Item::getKeyUid()
{
	return m_keyUid;
}
} // namespace Onboarding
} // namespace Startup
} // namespace Modules