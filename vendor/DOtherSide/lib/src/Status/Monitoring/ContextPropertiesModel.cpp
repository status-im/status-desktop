#include "DOtherSide/Status/Monitoring/ContextPropertiesModel.h"

ContextPropertiesModel::ContextPropertiesModel(QObject* parent)
    : QAbstractListModel(parent)
{
}

int ContextPropertiesModel::rowCount(const QModelIndex &parent) const
{
    return m_contextProperties.size();
}

QVariant ContextPropertiesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return {};

    return m_contextProperties.at(index.row());
}

QHash<int, QByteArray> ContextPropertiesModel::roleNames() const
{
   static QHash<int, QByteArray> roles {
       { NameRole, QByteArrayLiteral("name") }
   };

   return roles;
}

void ContextPropertiesModel::addContextProperty(const QString &property)
{
    if (m_contextProperties.contains(property))
        return;

    const auto currentCount = m_contextProperties.size();
    beginInsertRows(QModelIndex(), currentCount, currentCount);
    m_contextProperties << property;
    endInsertRows();
}
