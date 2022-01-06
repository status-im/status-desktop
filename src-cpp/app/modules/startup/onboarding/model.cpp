#include "model.h"
#include <QAbstractListModel>
#include <QDebug>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
Model::Model(QObject* parent)
	: QAbstractListModel(parent)
{ }

QHash<int, QByteArray> Model::roleNames() const
{
	QHash<int, QByteArray> roles;
	roles[Id] = "accountId";
	roles[Alias] = "username";
	roles[Identicon] = "identicon";
	roles[Address] = "address";
	roles[KeyUid] = "keyUid";
	return roles;
}

int Model::rowCount(const QModelIndex& parent = QModelIndex()) const
{
	return m_items.size();
}

QVariant Model::data(const QModelIndex& index, int role) const
{
	if(!index.isValid())
	{
		return QVariant();
	}

	if(index.row() < 0 || index.row() > m_items.size())
	{
		return QVariant();
	}

	Item item = m_items[index.row()];

	switch(role)
	{
	case Id: return QVariant(item.getId());
	case Alias: return QVariant(item.getAlias());
	case Identicon: return QVariant(item.getIdenticon());
	case Address: return QVariant(item.getAddress());
	case KeyUid: return QVariant(item.getKeyUid());
	}

	return QVariant();
}

void Model::setItems(QVector<Item> items)
{
	beginResetModel();
	m_items = items;
	endResetModel();
}

} // namespace Onboarding
} // namespace Startup
} // namespace Modules