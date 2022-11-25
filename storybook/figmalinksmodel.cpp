#include "figmalinksmodel.h"

FigmaLinksModel::FigmaLinksModel(const QStringList &links, QObject *parent)
    : QAbstractListModel{parent}, m_links{links}
{
}

int FigmaLinksModel::rowCount(const QModelIndex &parent) const
{
    return m_links.size();
}

QVariant FigmaLinksModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid))
        return {};

    const int row = index.row();
    return m_links.at(row);
}

QHash<int, QByteArray> FigmaLinksModel::roleNames() const
{
    static QHash<int, QByteArray> roles(
                {{LinkRole, QByteArrayLiteral("link")}});
    return roles;
}

void FigmaLinksModel::setContent(const QStringList &links)
{
    if (m_links == links)
        return;

    const auto oldCount = m_links.size();

    beginResetModel();
    m_links = links;
    endResetModel();

    if (m_links.size() != oldCount)
        emit countChanged();
}
