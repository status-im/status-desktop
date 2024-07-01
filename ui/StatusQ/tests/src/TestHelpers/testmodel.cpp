#include "testmodel.h"

#include <algorithm>

TestModel::TestModel(QList<QPair<QString, QVariantList>> data)
    : m_data(std::move(data))
{
    initRoles();
}

TestModel::TestModel(QList<QString> roles)
{
    QList<QPair<QString, QVariantList>> data;
    data.reserve(roles.size());

    for (auto& role : roles)
        data.append({std::move(role), {}});

    m_data = std::move(data);
    initRoles();
}

int TestModel::rowCount(const QModelIndex& parent) const
{
    if(parent.isValid())
        return 0;

    Q_ASSERT(m_data.size());
    return m_data.first().second.size();
}

QHash<int, QByteArray> TestModel::roleNames() const
{
    return m_roles;
}

QVariant TestModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || role < 0 || role >= m_data.size())
        return {};

    const auto row = index.row();

    if (role >= m_data.length() || row >= m_data.at(0).second.length())
        return {};

    return m_data.at(role).second.at(row);
}

void TestModel::insert(int index, QVariantList row)
{
    beginInsertRows(QModelIndex{}, index, index);

    Q_ASSERT(row.size() == m_data.size());

    for (int i = 0; i < m_data.size(); i++) {
        auto& roleVariantList = m_data[i].second;
        Q_ASSERT(index <= roleVariantList.size());
        roleVariantList.insert(index, std::move(row[i]));
    }

    endInsertRows();
}

void TestModel::update(int index, int role, QVariant value)
{
    Q_ASSERT(role < m_data.size() && index < m_data[role].second.size());
    m_data[role].second[index].setValue(std::move(value));

    emit dataChanged(this->index(index, 0), this->index(index, 0), { role });
}

void TestModel::remove(int index)
{
    beginRemoveRows(QModelIndex{}, index, index);

    for (int i = 0; i < m_data.size(); i++) {
        auto& roleVariantList = m_data[i].second;
        Q_ASSERT(index < roleVariantList.size());
        roleVariantList.removeAt(index);
    }

    endRemoveRows();
}

void TestModel::invert()
{
    if (rowCount() < 2)
        return;

    emit layoutAboutToBeChanged();

    for (auto& entry : m_data)
        std::reverse(entry.second.begin(), entry.second.end());

    const auto persistentIndexes = persistentIndexList();
    const auto count = rowCount();

    for (const QModelIndex& index: persistentIndexes)
        changePersistentIndex(index, createIndex(count - index.row() - 1, 0));

    emit layoutChanged();
}

void TestModel::removeEverySecond()
{
    if (m_data.empty())
        return;

    emit layoutAboutToBeChanged();

    for (auto& entry : m_data) {
        QVariantList& data = entry.second;

        for (auto i = 0; i < data.size(); i++)
            data.removeAt(i);
    }

    const auto persistentIndexes = persistentIndexList();

    for (const QModelIndex& index : persistentIndexes) {
        if (index.row() % 2 == 0)
            changePersistentIndex(index, {});
        else
            changePersistentIndex(index, createIndex(index.row() / 2, 0));
    }

    emit layoutChanged();
}

void TestModel::reset()
{
    beginResetModel();
    endResetModel();
}

void TestModel::resetAndClear()
{
    beginResetModel();
    std::for_each(m_data.begin(), m_data.end(), [](auto& e) {
        e.second.clear();
    });
    endResetModel();
}

void TestModel::initRoles()
{
    m_roles.reserve(m_data.size());

    for (auto i = 0; i < m_data.size(); i++)
        m_roles.insert(i, m_data.at(i).first.toUtf8());
}
