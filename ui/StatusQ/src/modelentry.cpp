#include "StatusQ/modelentry.h"

#include "StatusQ/snapshotmodel.h"
#include "StatusQ/snapshotobject.h"

ModelEntry::ModelEntry(QObject* parent)
    : QObject(parent)
    , m_item(new QQmlPropertyMap(this))
{ }

QQmlPropertyMap* ModelEntry::item() const
{
    return m_item.data();
}

QAbstractItemModel* ModelEntry::sourceModel() const
{
    return m_sourceModel.data();
}

QString ModelEntry::key() const
{
    return m_key;
}

QVariant ModelEntry::value() const
{
    return m_value;
}

bool ModelEntry::available() const
{
    return m_available;
}

const QStringList& ModelEntry::roles() const
{
    return m_roles;
}

int ModelEntry::row() const
{
    return m_row;
}

bool ModelEntry::cacheOnRemoval() const
{
    return m_cacheOnRemoval;
}

bool ModelEntry::itemRemovedFromModel() const
{
    return m_itemRemovedFromModel;
}

void ModelEntry::setSourceModel(QAbstractItemModel* sourceModel)
{
    if(m_sourceModel == sourceModel) return;

    if(m_sourceModel)
    {
        disconnect(m_sourceModel, nullptr, this, nullptr);
    }
    m_sourceModel = sourceModel;

    resetCachedItem();
    resetIndex();

    if(!m_sourceModel)
    {
        emit sourceModelChanged();
        return;
    }

    connect(m_sourceModel, &QAbstractItemModel::modelReset, this, [this]() { resetIndex(); });
    connect(m_sourceModel, &QAbstractItemModel::rowsInserted, this, [this]() {
        if(!m_index.isValid())
        {
            resetIndex();
        }
    });
    connect(m_sourceModel,
            &QAbstractItemModel::rowsMoved,
            this,
            [this](const QModelIndex& parent, int start, int end, const QModelIndex& destination, int row) {
                if(!m_index.isValid()) return;

                if(m_index.row() >= destination.row() && m_index.row() <= destination.row() + (end - start))
                {
                    emit rowChanged();
                }
            });
    connect(m_sourceModel,
            &QAbstractItemModel::rowsAboutToBeRemoved,
            this,
            [this](const QModelIndex& parent, int first, int last) {
                if(!m_index.isValid()) return;

                if(m_index.row() < first || m_index.row() > last) return;

                if(m_cacheOnRemoval)
                {
                    cacheItem();
                    setItemRemovedFromModel(true);
                    setRow(-1);
                    return;
                }
                setAvailable(false);
                setIndex({});
            });
    connect(m_sourceModel,
            &QAbstractItemModel::dataChanged,
            this,
            [this](const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>& roles) {

                auto keysForRole = m_sourceModel->roleNames().keys(m_key.toUtf8());

                if (keysForRole.isEmpty())
                    return;

                auto keyRole = keysForRole.first();

                if(!m_index.isValid())
                {
                    if(!roles.empty() && !roles.contains(keyRole))
                        return;

                    auto index = findIndexInRange(topLeft.row(), bottomRight.row() + 1);
                    setIndex(index);
                    return;
                }

                if(m_index.data(keyRole) != m_value)
                {
                    auto index = findIndexInRange(m_index.row(), m_index.row() + 1);
                    setIndex(index);
                    return;
                }

                if(topLeft.row() <= m_index.row() && m_index.row() <= bottomRight.row())
                {
                    updateItem(roles);
                }
            });
    connect(m_sourceModel, &QAbstractItemModel::layoutChanged, this, [this]() {
        if(!m_index.isValid())
        {
            // Resetting just to cover cases where the rows are removed after the layout change
            resetItem();
        }
        setRow(m_index.row());
    });

    emit sourceModelChanged();
}

void ModelEntry::setKey(const QString& key)
{
    if(m_key == key) return;

    m_key = key;
    resetIndex();
    emit keyChanged();
}

void ModelEntry::setValue(const QVariant& value)
{
    if(m_value == value) return;

    m_value = value;
    resetIndex();
    emit valueChanged();
}

void ModelEntry::setIndex(const QModelIndex& index)
{
    if(m_index == index) return;

    m_index = index;

        setRow(m_index.row());
        tryItemResetOrUpdate();
}

void ModelEntry::setAvailable(bool available)
{
    if(available == m_available) return;

    m_available = available;
    emit availableChanged();
}

void ModelEntry::setRoles(const QStringList& roles)
{
    if(m_roles.size() == roles.size() && !m_roles.empty() &&
       std::all_of(roles.begin(), roles.end(), [this](const QString& role) { return m_roles.contains(role); }))
        return;

    m_roles = roles;
    emit rolesChanged();
}

void ModelEntry::setRow(int row)
{
    if(m_row == row) return;

    m_row = row;
    emit rowChanged();
}

void ModelEntry::setCacheOnRemoval(bool cacheOnRemoval)
{
    if(m_cacheOnRemoval == cacheOnRemoval) return;

    resetCachedItem();

    m_cacheOnRemoval = cacheOnRemoval;
    emit cacheOnRemovalChanged();
}

void ModelEntry::setItemRemovedFromModel(bool itemRemovedFromModel)
{
    if(m_itemRemovedFromModel == itemRemovedFromModel) return;

    m_itemRemovedFromModel = itemRemovedFromModel;
    emit itemRemovedFromModelChanged();
}

QModelIndex ModelEntry::findIndexInRange(int start, int end) const
{
    if(!m_sourceModel || m_key.isEmpty()) return {};

    auto keysForRole = m_sourceModel->roleNames().keys(m_key.toUtf8());

    // no matching roles found
    if(keysForRole.isEmpty()) return {};

    for(int i = start; i < end; i++)
    {
        auto index = m_sourceModel->index(i, 0);
        auto data = index.data(keysForRole.first());
        if(data == m_value) return index;
    }

    return {};
}

void ModelEntry::resetIndex()
{
    auto index = QModelIndex();
    if(m_sourceModel) index = findIndexInRange(0, m_sourceModel->rowCount());

    setIndex(index);
}

void ModelEntry::tryItemResetOrUpdate()
{
    if(!m_index.isValid() || !itemHasCorrectRoles())
    {
        resetItem();
        return;
    }

    updateItem();
    setAvailable(true);
}

void ModelEntry::resetItem()
{
    // Signal order is important here
    if(!m_index.isValid())
    {
        setAvailable(false);
    }

    m_item.reset(new QQmlPropertyMap());

    fillItem();

    if(!m_index.isValid())
    {
        setRoles(m_item->keys());
    }

    emit itemChanged();

    if(m_index.isValid())
    {
        setRoles(m_item->keys());
        setAvailable(true);
    }
}

void ModelEntry::updateItem(const QVector<int>& roles)
{
    const auto updatedRoles = fillItem(roles);
    notifyItemChanges(updatedRoles);

    setItemRemovedFromModel(false);
}

QStringList ModelEntry::fillItem(const QVector<int>& roles)
{
    if(!m_index.isValid() || !m_sourceModel) return {};

    QStringList filledRoles;
    const auto& rolesRef = roles.isEmpty() ? m_sourceModel->roleNames().keys().toVector() : roles;

    for(auto role : rolesRef)
    {
        auto roleName = m_sourceModel->roleNames().value(role);
        auto roleValue = m_index.data(role);

        if(roleValue == m_item->value(roleName)) continue;

        filledRoles.append(roleName);
        m_item->insert(roleName, roleValue);
    }

    return filledRoles;
}

void ModelEntry::notifyItemChanges(const QStringList& roles)
{
    if (roles.contains(m_key))
    {
        emit itemChanged();
        return;
    }

    for(auto role : roles)
    {
        auto value = m_item->value(role);
        emit m_item->valueChanged(role, value);
    }
}

bool ModelEntry::itemHasCorrectRoles() const
{
    if(!m_sourceModel || !m_item) return false;

    auto itemKeys = m_item->keys();
    auto modelRoles = m_sourceModel->roleNames().values();

    return std::all_of(modelRoles.cbegin(),
                       modelRoles.cend(),
                       [itemKeys](const QByteArray& role) { return itemKeys.contains(role); }) &&
           itemKeys.size() == modelRoles.size();
}

void ModelEntry::cacheItem()
{
    if(!m_cacheOnRemoval) return;

    for(const auto& role : std::as_const(m_roles))
    {
        auto roleNames = m_sourceModel->roleNames().keys(role.toUtf8());
        if (roleNames.isEmpty()) continue;

        auto roleName = roleNames.first();
        auto roleValue = m_index.data(roleName);

        // Note: relying on QVariant::canConvert is not possible in this case
        // because of https://bugreports.qt.io/browse/QTBUG-135619 (different
        // behavior for Qt 5 and 6
        const QObject* obj = roleValue.value<QObject*>();

        if(!obj)
            continue;

        if(auto model = qobject_cast<const QAbstractItemModel*>(obj))
        {
            m_item->insert(role, QVariant::fromValue(new SnapshotModel(
                                     *model, true, m_item.data())));
        }
        else
        {
            const auto snapshot = new SnapshotObject(obj, m_item.data());
            m_item->insert(role, QVariant::fromValue(snapshot->snapshot()));
        }
    }
}

void ModelEntry::resetCachedItem()
{
    if(!m_cacheOnRemoval || !m_itemRemovedFromModel) return;

    resetIndex();
    tryItemResetOrUpdate();
    setItemRemovedFromModel(false);
}
