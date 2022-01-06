#include "selected_account.h"
#include <QDebug>
#include <QObject>

namespace Modules
{
namespace Startup
{
namespace Login
{
SelectedAccount::SelectedAccount(QObject* parent)
	: QObject(parent)
{ }

void SelectedAccount::setSelectedAccountData(Item item)
{
	m_item = item;
}
QString SelectedAccount::getName()
{
	return m_item.getName();
}
QString SelectedAccount::getIdenticon()
{
	return m_item.getIdenticon();
}

QString SelectedAccount::getKeyUid()
{
	return m_item.getKeyUid();
}

QString SelectedAccount::getThumbnailImage()
{
	return m_item.getThumbnailImage();
}

QString SelectedAccount::getLargeImage()
{
	return m_item.getLargeImage();
}
} // namespace Login
} // namespace Startup
} // namespace Modules