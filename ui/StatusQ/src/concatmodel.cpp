#include "StatusQ/concatmodel.h"

#include <QDebug>

SourceModel::SourceModel(QObject* parent)
    : QObject{parent}
{
}

void SourceModel::setModel(QAbstractItemModel* model)
{
    if (m_model == model)
        return;

    if (model)
        connect(model, &QObject::destroyed, this, &SourceModel::onModelDestroyed);

    if (m_model)
        disconnect(m_model, &QObject::destroyed, this, &SourceModel::onModelDestroyed);

    emit modelAboutToBeChanged();
    m_model = model;
    emit modelChanged(false);
}

QAbstractItemModel* SourceModel::model() const
{
    return m_model;
}

void SourceModel::setMarkerRoleValue(const QString& markerRoleValue)
{
    if (m_markerRoleValue == markerRoleValue)
        return;

    m_markerRoleValue = markerRoleValue;
    emit markerRoleValueChanged();
}

const QString& SourceModel::markerRoleValue() const
{
    return m_markerRoleValue;
}

void SourceModel::onModelDestroyed()
{
    m_model = nullptr;
    emit modelChanged(true);
}


ConcatModel::ConcatModel(QObject* parent)
    : QAbstractListModel{parent}
{
}

QQmlListProperty<SourceModel> ConcatModel::sources()
{
    QQmlListProperty<SourceModel> listProperty(this, &m_sources);

    listProperty.replace = nullptr;
    listProperty.clear = nullptr;
    listProperty.removeLast = nullptr;

    listProperty.append = [](auto listProperty, auto element) {
        ConcatModel* model = qobject_cast<ConcatModel*>(listProperty->object);

        if (model->m_initialized) {
            qWarning() << "Adding sources dynamically is not supported.";
            return;
        }

        model->m_sources.append(element);
    };

    return listProperty;
}

void ConcatModel::setMarkerRoleName(const QByteArray& markerRoleName)
{
    if (m_markerRoleName == markerRoleName)
        return;

    if (m_markerRoleName != s_defaultMarkerRoleName || m_initialized) {
        qWarning() << "Property \"markerRoleName\" is intended to be "
                      "initialized once before roles initialization and not "
                      "modified later.";
        return;
    }

    m_markerRoleName = markerRoleName;
    emit markerRoleNameChanged();
}

const QByteArray& ConcatModel::markerRoleName() const
{
    return m_markerRoleName;
}

void ConcatModel::setExpectedRoles(const QStringList& expectedRoles)
{
    if (m_expectedRoles == expectedRoles)
        return;

    if (!m_expectedRoles.isEmpty()) {
        qWarning() << "Property \"expectedRoles\" is intended "
                      "to be initialized once and not changed!";
        return;
    }

    m_expectedRoles = expectedRoles;
    emit expectedRolesChanged();
}

const QStringList& ConcatModel::expectedRoles() const
{
    return m_expectedRoles;
}

int ConcatModel::sourceModelRow(int row) const
{
    auto source = sourceForIndex(row);
    return source.first != nullptr ? source.second : -1;
}

QAbstractItemModel* ConcatModel::sourceModel(int row) const
{
    auto source = sourceForIndex(row);
    return source.first != nullptr ? source.first->model() : nullptr;
}

int ConcatModel::fromSourceRow(const QAbstractItemModel* model, int row) const
{
    if (model == nullptr || row < 0 || model->rowCount() <= row)
        return -1;

    auto it = std::find_if(m_sources.cbegin(), m_sources.cend(),
                           [model](auto source) {
        return source->model() == model;
    });

    if (it == m_sources.cend())
        return -1;

    return countPrefix(it - m_sources.begin()) + row;
}

int ConcatModel::rowCount(const QModelIndex& parent) const
{
    if (!m_initialized)
        return 0;

    return rowCountInternal();
}

QVariant ConcatModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid))
        return {};

    auto row = index.row();
    int rowCount = 0;

    for (int i = 0; i < m_sources.size(); i++) {
        const int subRowCount = m_rowCounts[i];

        if (rowCount + subRowCount > row) {
            auto source = m_sources[i];

            if (role == m_markerRole)
                return source->markerRoleValue();

            auto model = source->model();

            if (model == nullptr)
                return {};

            auto& mapping = m_rolesMappingToSource.at(i);
            auto it = mapping.find(role);

            if (it == mapping.end())
                return {};

            return model->data(model->index(row - rowCount, 0), it->second);
        }

        rowCount += subRowCount;
    }

    return {};
}

QHash<int, QByteArray> ConcatModel::roleNames() const
{
    return m_roleNames;
}

void ConcatModel::classBegin()
{
}

void ConcatModel::componentComplete()
{
    if (m_initialized)
        return;

    for (auto i = 0; i < m_sources.size(); i++) {
        SourceModel* source = m_sources[i];

        connect(source, &SourceModel::modelAboutToBeChanged, this,
                [this, i, source]()
        {
            auto model = source->model();

            if (model != nullptr)
                disconnectModelSlots(model);

            if (auto count = m_rowCounts[i]) {
                auto prefix = countPrefix(i);
                beginRemoveRows({}, prefix, prefix + count - 1);
            }
        });

        connect(source, &SourceModel::modelChanged, this,
                [this, source, i](bool deleted)
        {
            auto previousRowCount = m_rowCounts[i];

            if (deleted) {
                auto prefix = countPrefix(i);
                beginRemoveRows({}, prefix, prefix + previousRowCount - 1);
            }

            if (previousRowCount) {
                m_rowCounts[i] = 0;
                endRemoveRows();
            }

            auto model = source->model();

            if (model == nullptr)
                return;

            auto rowCount = model->rowCount();

            if (rowCount > 0) {
                auto prefix = countPrefix(i);

                beginInsertRows({}, prefix, prefix + rowCount - 1);

                m_rowCounts[i] = rowCount;

                if (!m_initialized) {
                    initRoles();
                    initRolesMapping();
                    m_initialized = true;
                } else {
                    initRolesMapping(i, model);
                }

                endInsertRows();
            }

            connectModelSlots(i, model);
        });

        connect(source, &SourceModel::markerRoleValueChanged, this,
                [this, source, i]
        {
            auto count = this->m_rowCounts[i];

            if (count == 0)
                return;

            auto prefix = this->countPrefix(i);

            emit this->dataChanged(this->index(prefix),
                                   this->index(prefix + count - 1),
                                   { this->m_markerRole });
        });
    }

    initAllModelsSlots();
    fetchRowCounts();

    auto count = rowCountInternal();

    if (count == 0)
        return;

    beginInsertRows({}, 0, count - 1);

    initRoles();
    initRolesMapping();
    m_initialized = true;

    endInsertRows();
}

std::pair<SourceModel*, int> ConcatModel::sourceForIndex(int index) const
{
    if (index < 0)
        return {};

    int rowCount = 0;

    for (int i = 0; i < m_sources.size(); i++) {
        const int subRowCount = m_rowCounts[i];

        if (rowCount + subRowCount > index)
            return {m_sources[i], index - rowCount};

        rowCount += subRowCount;
    }

    return {};
}


void ConcatModel::initRoles()
{
    Q_ASSERT(m_roleNames.empty());
    Q_ASSERT(m_nameRoles.empty());

    m_nameRoles.reserve(m_expectedRoles.size() + 1);

    for (auto& expectedRoleName : qAsConst(m_expectedRoles))
        m_nameRoles.try_emplace(expectedRoleName.toUtf8(), m_nameRoles.size());

    for (auto sourceModel : qAsConst(m_sources)) {
        auto model = sourceModel->model();

        if (model == nullptr)
            continue;

        auto roleNames = model->roleNames();

        for (auto& role : roleNames)
            m_nameRoles.try_emplace(role, m_nameRoles.size());
    }

    auto it = m_nameRoles.try_emplace(m_markerRoleName,
                                      m_nameRoles.size()).first;
    m_markerRole = it->second;

    m_roleNames.reserve(m_nameRoles.size());

    for (auto& [name, role] : m_nameRoles)
        m_roleNames.insert(role, name);
}

void ConcatModel::initRolesMapping(int index, QAbstractItemModel* model)
{
    Q_ASSERT(model != nullptr);

    auto roleNames = model->roleNames();
    auto rowCount = model->rowCount();

    std::unordered_map<int, int> fromSource;
    std::unordered_map<int, int> toSource;

    for (auto i = roleNames.cbegin(), end = roleNames.cend(); i != end; ++i) {
        auto it = std::as_const(m_nameRoles).find(i.value());

        if (it == m_nameRoles.cend())
            continue;

        auto globalRole = it->second;

        fromSource.insert({i.key(), globalRole});
        toSource.insert({globalRole, i.key()});
    }

    bool initialized = !roleNames.empty() || rowCount > 0;

    m_rolesMappingFromSource[index] = std::move(fromSource);
    m_rolesMappingToSource[index] = std::move(toSource);
    m_rolesMappingInitializationFlags[index] = initialized;
}

void ConcatModel::initRolesMapping()
{
    Q_ASSERT(m_rolesMappingFromSource.empty());
    Q_ASSERT(m_rolesMappingToSource.empty());
    Q_ASSERT(m_rolesMappingInitializationFlags.empty());

    m_rolesMappingFromSource.resize(m_sources.size());
    m_rolesMappingToSource.resize(m_sources.size());
    m_rolesMappingInitializationFlags.resize(m_sources.size(), false);

    for (auto i = 0; i < m_sources.size(); ++i) {
        auto sourceModelWrapper = m_sources.at(i);
        auto sourceModel = sourceModelWrapper->model();

        if (sourceModel == nullptr)
            continue;

        initRolesMapping(i, sourceModel);
    }
}

void ConcatModel::initAllModelsSlots()
{
    for (auto sourceIndex = 0; sourceIndex < m_sources.size(); ++sourceIndex) {
        auto sourceModelWrapper = m_sources.at(sourceIndex);
        auto sourceModel = sourceModelWrapper->model();

        if (sourceModel)
            connectModelSlots(sourceIndex, sourceModel);
    }
}

void ConcatModel::connectModelSlots(int index, QAbstractItemModel *model)
{
    connect(model, &QAbstractItemModel::rowsAboutToBeInserted, this,
            [this, index](const QModelIndex &parent, int first, int last)
    {
        auto prefix = this->countPrefix(index);
        this->beginInsertRows({}, first + prefix, last + prefix);
    });

    connect(model, &QAbstractItemModel::rowsInserted, this,
            [this, model, index](const QModelIndex &parent, int first, int last)
    {
        m_rowCounts[index] += last - first + 1;

        if (!m_initialized) {
            initRoles();
            initRolesMapping();
            m_initialized = true;
        } else if (!m_rolesMappingInitializationFlags.at(index)) {
            initRolesMapping(index, model);
        }

        this->endInsertRows();
    });

    connect(model, &QAbstractItemModel::rowsAboutToBeRemoved, this,
            [this, index](const QModelIndex &parent, int first, int last)
    {
        auto prefix = this->countPrefix(index);
        this->beginRemoveRows({}, first + prefix, last + prefix);
    });

    connect(model, &QAbstractItemModel::rowsRemoved, this,
            [this, index](const QModelIndex &parent, int first, int last)
    {
        m_rowCounts[index] -= last - first + 1;
        this->endRemoveRows();
    });

    connect(model, &QAbstractItemModel::rowsAboutToBeMoved, this,
            [this, index](
                const QModelIndex&, int sourceStart, int sourceEnd,
                const QModelIndex&, int destinationRow)
    {
        auto prefix = this->countPrefix(index);
        this->beginMoveRows({}, sourceStart + prefix, sourceEnd + prefix,
                            {}, destinationRow + prefix);
    });

    connect(model, &QAbstractItemModel::rowsMoved, this,
            [this, index]
    {
        this->endMoveRows();
    });

    connect(model, &QAbstractItemModel::layoutAboutToBeChanged, this, [this]
    {
        emit this->layoutAboutToBeChanged();
    });

    connect(model, &QAbstractItemModel::layoutAboutToBeChanged, this, [this]
    {
        emit this->layoutChanged();
    });

    connect(model, &QAbstractItemModel::modelAboutToBeReset, this, [this]
    {
        this->beginResetModel();
    });

    connect(model, &QAbstractItemModel::modelReset, this, [this, model, index]
    {
        m_rowCounts[index] = model->rowCount();
        m_rolesMappingInitializationFlags[index] = false;

        this->endResetModel();
    });

    connect(model, &QAbstractItemModel::dataChanged, this,
            [this, index](auto& topLeft, const auto& bottomRight, auto& roles)
    {
        auto prefix = this->countPrefix(index);
        auto rolesTranslated = translateRoles(index, roles);

        if (rolesTranslated.empty())
            return;

        emit this->dataChanged(this->index(prefix + topLeft.row()),
                               this->index(prefix + bottomRight.row()),
                               rolesTranslated);
    });
}

void ConcatModel::disconnectModelSlots(QAbstractItemModel* model)
{
    Q_ASSERT(model != nullptr);
    bool disconnected = disconnect(model, nullptr, this, nullptr);
    Q_UNUSED(disconnected);
    Q_ASSERT(disconnected);
}

int ConcatModel::rowCountInternal() const
{
    return std::reduce(m_rowCounts.cbegin(), m_rowCounts.cend());
}

int ConcatModel::countPrefix(int sourceIndex) const
{
    Q_ASSERT(sourceIndex >= 0 && sourceIndex < m_sources.size());
    return std::reduce(m_rowCounts.cbegin(), m_rowCounts.cbegin() + sourceIndex);
}

void ConcatModel::fetchRowCounts()
{
    m_rowCounts.resize(m_sources.size());

    for (auto i = 0; i < m_sources.size(); ++i) {
        auto sourceModelWrapper = m_sources.at(i);
        auto sourceModel = sourceModelWrapper->model();

        m_rowCounts[i] = (sourceModel == nullptr) ? 0 : sourceModel->rowCount();
    }
}

QVector<int> ConcatModel::translateRoles(int sourceIndex,
                                         const QVector<int>& roles) const
{
    QVector<int> translated;
    translated.reserve(roles.size());

    auto& mapping = m_rolesMappingFromSource[sourceIndex];

    for (auto role : roles) {
        auto it = mapping.find(role);

        if (it != mapping.end())
            translated << it->second;
    }

    return translated;
}
