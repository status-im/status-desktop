#include "StatusQ/concatmodel.h"

#include <QDebug>

/*!
    \qmltype SourceModel
    \instantiates SourceModel
    \inqmlmodule StatusQ
    \inherits QtObject
    \brief Wraps arbitrary QAbstractItemModel to be concatenated with other
    models within a \l {ConcatModel}.

    It allows assigning a value of a special marker role in ConcatModel for the
    given model.
*/

/*!
    \qmltype ConcatModel
    \instantiates ConcatModel
    \inqmlmodule StatusQ
    \inherits QAbstractListModel
    \brief Proxy model concatenating vertically multiple source models.

    It allows concatenating multiple source models, with same roles, partially
    different roles or even totally different roles. The model performs necessary
    roles mapping internally.

    The proxy is similar to \l {QConcatenateTablesProxyModel} but QML-ready,
    performing all necessary role names remapping.

    Roles are established when the first item appears in one of the sources.
    Expected roles can be also declared up-front using expectedRoles property
    (because on first insertion some roles may be not yet available via
    roleNames() on other models).

    Additionally the model introduces an extra role with a name configurable via
    \l {CocatModel::markerRoleName}. Value of this role may be set separately
    for each source model in \l {SourceModel} wrapper. This allows to easily
    create inserts between models using \l {ListView}'s sections mechanism.

    \qml
    ListModel {
        id: firstModel

        ListElement { name: "entry 1_1" }
        ListElement { name: "entry 1_2" }
        ListElement { name: "entry 1_3" }
    }

    ListModel {
        id: secondModel

        ListElement {
            name: "entry 1_2"
            key: 1
        }
        ListElement {
            key: 2
            name: "entry 2 _2"
        }
    }

    ConcatModel {
        id: concatModel

        sources: [
            SourceModel {
                model: firstModel
                markerRoleValue: "first_model"
            },
            SourceModel {
                model: secondModel
                markerRoleValue: "second_model"
            }
        ]

        markerRoleName: "which_model"
        expectedRoles: ["key", "name"]
    }
    \endqml
*/

SourceModel::SourceModel(QObject* parent)
    : QObject{parent}
{
}

void SourceModel::setModel(QAbstractItemModel* model)
{
    if (m_model == model)
        return;

    emit modelAboutToBeChanged();
    m_model = model;
    emit modelChanged();
}

/*!
    \qmlproperty any StatusQ::SourceModel::model

    The model that will be concatenated with other models within ConcatModel.
*/
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

/*!
    \qmlproperty string StatusQ::SourceModel::markerRoleValue

    The value that will be exposed from the ConcatModel through the role named
    according to \l {ConcatModel::markerRoleName} for the entries coming from
    the model defined in SourceModel::model.
*/
const QString& SourceModel::markerRoleValue() const
{
    return m_markerRoleValue;
}


ConcatModel::ConcatModel(QObject* parent)
    : QAbstractListModel{parent}
{
}

/*!
    \qmlproperty list<SourceModel> StatusQ::ConcatModel::sources

    This property holds the list of \l {SourceModel} wrappers. Every wrapper
    holds model which is intended to be concatenated with others within the
    proxy.
*/
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

void ConcatModel::setMarkerRoleName(const QString& markerRoleName)
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

/*!
    \qmlproperty string StatusQ::ConcatModel::markerRoleName

    This property contains the name of an extra role allowing to distinguish
    source models from the delegate level.
*/
const QString& ConcatModel::markerRoleName() const
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

/*!
    \qmlproperty list<string> StatusQ::ConcatModel::expectedRoles

    This property allows to predefine a set of roles exposed by ConcatModel.
    This is useful when roles are not initially defined for some source models.
    For example, for ListModel, roles are not defined as long as the model is
    empty.
*/
const QStringList& ConcatModel::expectedRoles() const
{
    return m_expectedRoles;
}

void ConcatModel::setPropagateResets(bool propagateResets)
{
    if (m_propagateResets == propagateResets)
        return;

    m_propagateResets = propagateResets;
    emit propagateResetsChanged();
}

/*!
    \qmlproperty list<string> StatusQ::ConcatModel::propagateResets

    When set to true, model resets on source models result with model reset of
    the ConcatModel. Otherwise model resets of sources are handled as removals
    and insertions. Default is false.
*/
bool ConcatModel::propagateResets() const
{
    return m_propagateResets;
}

/*!
    \qmlmethod int StatusQ::ConcatModel::sourceModelRow(row)

    Returns the row index inside the source model for a given row of the proxy.
*/
int ConcatModel::sourceModelRow(int row) const
{
    auto source = sourceForIndex(row);
    return source.first != nullptr ? source.second : -1;
}

/*!
    \qmlmethod QAbstractItemModel* StatusQ::ConcatModel::sourceModel(row)

    Returns the source model for a given row of the proxy.
*/
QAbstractItemModel* ConcatModel::sourceModel(int row) const
{
    auto source = sourceForIndex(row);
    return source.first != nullptr ? source.first->model() : nullptr;
}

/*!
    \qmlmethod int StatusQ::ConcatModel::fromSourceRow(model, row)

    Returns the row number of the ConcatModel for a given source model and
    source model's row index.
*/
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

            auto& mapping = m_rolesMappingToSource[i];
            auto it = mapping.find(role);

            if (it == mapping.end())
                return {};

            return model->data(model->index(row - rowCount, 0), it->second);
        }

        rowCount += subRowCount;
    }

    return {};
}

bool ConcatModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid))
        return false;

    const auto row = index.row();
    
    const auto source = sourceForIndex(row);
    if (source.first == nullptr)
        return false;
    
    const auto model = source.first->model();
    if (model == nullptr)
        return false;

    const auto sourcePosition = m_sources.indexOf(source.first);
    if (sourcePosition == -1)
        return false;
        
    const auto& mapping = m_rolesMappingToSource[sourcePosition];
    const auto it = mapping.find(role);

    if (it == mapping.end())
        return false;

    const auto sourceIndex = model->index(source.second, 0);
    if(!sourceIndex.isValid())
        return false;

    return model->setData(sourceIndex, value, it->second);
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
                [this, source, i]()
        {
            auto previousRowCount = m_rowCounts[i];

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

    for (const auto& expectedRoleName : std::as_const(m_expectedRoles))
        m_nameRoles.try_emplace(expectedRoleName.toUtf8(), m_nameRoles.size());

    for (auto sourceModel : std::as_const(m_sources)) {
        auto model = sourceModel->model();

        if (model == nullptr)
            continue;

        auto roleNames = model->roleNames();

        for (auto& role : roleNames)
            m_nameRoles.try_emplace(role, m_nameRoles.size());
    }

    auto it = m_nameRoles.try_emplace(m_markerRoleName.toUtf8(),
                                      m_nameRoles.size()).first;
    m_markerRole = it->second;

    m_roleNames.reserve(m_nameRoles.size());

    for (const auto& [name, role] : m_nameRoles)
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
        auto sourceModelWrapper = m_sources[i];
        auto sourceModel = sourceModelWrapper->model();

        if (sourceModel == nullptr)
            continue;

        initRolesMapping(i, sourceModel);
    }
}

void ConcatModel::initAllModelsSlots()
{
    for (auto sourceIndex = 0; sourceIndex < m_sources.size(); ++sourceIndex) {
        auto sourceModelWrapper = m_sources[sourceIndex];
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
        } else if (!m_rolesMappingInitializationFlags[index]) {
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

    connect(model, &QAbstractItemModel::rowsMoved, this, [this]
    {
        this->endMoveRows();
    });

    connect(model, &QAbstractItemModel::layoutAboutToBeChanged, this,
            [this, model, index]
    {
        emit this->layoutAboutToBeChanged();

        const auto persistentIndexes = persistentIndexList();
        auto prefix = this->countPrefix(index);
        auto count = this->m_rowCounts[index];

        for (const QModelIndex& persistentIndex : persistentIndexes) {
            if (persistentIndex.row() < prefix || persistentIndex.row() >= count + prefix)
                continue;

            m_proxyIndexes << persistentIndex;
            Q_ASSERT(persistentIndex.isValid());
            const auto srcIndex = model->index(
                        persistentIndex.row() - prefix,
                        persistentIndex.column());

            Q_ASSERT(srcIndex.isValid());
            m_layoutChangePersistentIndexes << srcIndex;
        }
    });

    connect(model, &QAbstractItemModel::layoutChanged, this, [this, model, index]
    {
        auto prefix = this->countPrefix(index);
        auto oldCount = m_rowCounts[index];
        auto newCount = model->rowCount();
        auto countDiff = oldCount - newCount;

        // Update row count if necessary as it can change along with layout
        // change
        if (countDiff != 0)
            m_rowCounts[index] = newCount;

        for (int i = 0; i < m_proxyIndexes.size(); ++i) {
            auto p = m_layoutChangePersistentIndexes.at(i);

            changePersistentIndex(m_proxyIndexes.at(i), this->index(
                                      p.row() + prefix, p.column(), p.parent()));
        }

        // If count has changed, it's necessary to update all indexes relating
        // to the following source models (shift by countDiff).
        if (countDiff != 0) {
            const auto persistentIndexes = persistentIndexList();

            for (const QModelIndex& p : persistentIndexes) {
                if (p.row() < prefix + oldCount)
                    continue;

                changePersistentIndex(p, this->index(p.row() - countDiff,
                                                     p.column(), p.parent()));
            }
        }

        m_layoutChangePersistentIndexes.clear();
        m_proxyIndexes.clear();

        emit this->layoutChanged();
    });

    connect(model, &QAbstractItemModel::modelAboutToBeReset, this, [this, index]
    {
        if (!m_initialized)
            return;

        if (m_propagateResets) {
            this->beginResetModel();
            return;
        }

        auto currentCount = m_rowCounts[index];

        if (currentCount == 0)
            return;

        auto prefix = this->countPrefix(index);
        this->beginRemoveRows({}, prefix, prefix + currentCount - 1);
    });

    connect(model, &QAbstractItemModel::modelReset, this, [this, model, index]
    {
        auto count = model->rowCount();

        if (!m_initialized) {
            if (count != 0) {
                if (m_propagateResets)
                    this->beginResetModel();
                else
                    this->beginInsertRows({}, 0, count - 1);

                initRoles();
                initRolesMapping();
                m_initialized = true;

                m_rowCounts[index] = count;

                if (m_propagateResets)
                    this->endResetModel();
                else
                    this->endInsertRows();
            }
        } else {
            if (m_propagateResets) {
                initRolesMapping(index, model);
                m_rowCounts[index] = count;
                this->endResetModel();
            } else {
                auto previousCount = m_rowCounts[index];

                if (previousCount != 0) {
                    m_rowCounts[index] = 0;
                    this->endRemoveRows();
                }

                initRolesMapping(index, model);

                if (count != 0) {
                    auto prefix = this->countPrefix(index);
                    this->beginInsertRows({}, prefix, prefix + count - 1);

                    m_rowCounts[index] = count;

                    this->endInsertRows();
                }
            }
        }
    });

    connect(model, &QAbstractItemModel::dataChanged, this,
            [this, index](auto& topLeft, const auto& bottomRight, auto& roles)
    {
        auto prefix = this->countPrefix(index);
        auto rolesMapped = mapFromSourceRoles(index, roles);

        if (rolesMapped.empty())
            return;

        emit this->dataChanged(this->index(prefix + topLeft.row()),
                               this->index(prefix + bottomRight.row()),
                               rolesMapped);
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
        auto sourceModelWrapper = m_sources[i];
        auto sourceModel = sourceModelWrapper->model();

        m_rowCounts[i] = (sourceModel == nullptr) ? 0 : sourceModel->rowCount();
    }
}

QVector<int> ConcatModel::mapFromSourceRoles(
        int sourceIndex, const QVector<int>& sourceRoles) const
{
    QVector<int> mapped;
    if (sourceIndex < 0 || sourceIndex >= m_rolesMappingFromSource.size())
        return mapped;

    mapped.reserve(sourceRoles.size());

    auto& mapping = m_rolesMappingFromSource[sourceIndex];

    for (auto role : sourceRoles) {
        auto it = mapping.find(role);

        if (it != mapping.end())
            mapped << it->second;
    }

    return mapped;
}
