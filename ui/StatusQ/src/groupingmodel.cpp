#include "StatusQ/groupingmodel.h"

#include <iterator>

#include <QDebug>

namespace {

QVariant data(QAbstractItemModel* model, int row, int role) {
    return model->data(model->index(row, 0), role);
}

} // unnamed namespace


class RangeModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit RangeModel(QAbstractItemModel* sourceModel,
                        const std::vector<GroupingModel::Entry>& entries, int from, int to)
        : m_entries(entries), m_sourceModel(sourceModel), m_from(from), m_to(to)
    {
    }

    using QAbstractListModel::beginInsertRows;
    using QAbstractListModel::endInsertRows;
    using QAbstractListModel::beginRemoveRows;
    using QAbstractListModel::endRemoveRows;

    QVariant data(const QModelIndex& index, int role) const override
    {
        if (!index.isValid())
            return {};

        auto sourceIndex = m_entries[index.row() + m_from].sourceIndex;

        return m_sourceModel->data(m_sourceModel->index(sourceIndex,
                                                        index.column()), role);
    }

    QHash<int, QByteArray> roleNames() const override
    {
        return m_sourceModel->roleNames();
    }

    int rowCount(const QModelIndex& parent = {}) const override
    {
        return m_to - m_from + 1;
    }

    int& from()
    {
        return m_from;
    }

    int& to() {
        return m_to;
    }

    void shift(int offset)
    {
        m_from += offset;
        m_to += offset;
    }

private:
    QAbstractItemModel* m_sourceModel = nullptr;
    const std::vector<GroupingModel::Entry>& m_entries;
    int m_from = 0;
    int m_to = 0;
};

GroupingModel::GroupingModel(QObject* parent)
    : QAbstractProxyModel{parent}
{
}

GroupingModel::~GroupingModel() = default;

void GroupingModel::setSourceModel(QAbstractItemModel* model)
{
    if (sourceModel() == model)
        return;

    if (sourceModel() != nullptr)
        sourceModel()->disconnect(this);

    beginResetModel();

    QAbstractProxyModel::setSourceModel(model);

    if (model != nullptr)
        connectSignals(model);

    endResetModel();
}

QModelIndex GroupingModel::mapToSource(const QModelIndex& proxyIndex) const
{
    if (!sourceModel())
        return {};

    if (!proxyIndex.isValid())
        return {};

    if (proxyIndex.model() != sourceModel())
        return {};

    return index(m_submodels[proxyIndex.row()]->from());
}

QModelIndex GroupingModel::mapFromSource(const QModelIndex& sourceIndex) const
{
    if (!sourceIndex.isValid())
        return {};

    auto& entry = m_entries[sourceIndex.row()];
    auto submodel = entry.submodel;
    auto s = m_submodels[submodel].get();

    return s->index(entry.submodelIndex, 0);
}

void GroupingModel::setGroupingRoleName(const QString& groupingRoleName)
{
    if (m_groupingRoleName == groupingRoleName)
        return;

    m_groupingRoleName = groupingRoleName;

    initSubmodelRole();

    if (m_groupingRole)
        init();

    emit groupingRoleNameChanged();
}

const QString &GroupingModel::groupingRoleName() const
{
    return m_groupingRoleName;
}

void GroupingModel::setSubmodelRoleName(const QString& submodelRoleName)
{
    if (m_submodelRoleName == submodelRoleName)
        return;

    if (!m_roleNames.isEmpty())
        beginResetModel();

    m_submodelRoleName = submodelRoleName;

    if (!m_roleNames.isEmpty())
        endResetModel();

    emit submodelRoleNameChanged();
}

const QString& GroupingModel::submodelRoleName() const
{
    return m_submodelRoleName;
}

QVariant GroupingModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_submodels.size())
        return {};

    if (role == m_submodelRole)
        return QVariant::fromValue(m_submodels[index.row()].get());

    auto row = index.row();

    auto destRow = m_submodels[row]->from();
    auto srcRow = m_entries.at(destRow).sourceIndex;

    return sourceModel()->data(sourceModel()->index(srcRow, index.column()), role);
}

QHash<int, QByteArray> GroupingModel::roleNames() const
{
    return m_roleNames;
}

int GroupingModel::columnCount(const QModelIndex& parent) const
{
    if (parent.isValid())
        return 0;

    return 1;
}

int GroupingModel::rowCount(const QModelIndex &parent) const
{
    return m_submodels.size();
}

QModelIndex GroupingModel::index(int row, int column, const QModelIndex& parent) const
{
    if (parent.isValid())
        return {};

    if (row < 0 || column < 0 || row >= rowCount(parent)
            || column >= columnCount(parent))
        return {};

    return createIndex(row, column);
}

QModelIndex GroupingModel::parent(const QModelIndex& child) const
{
    return {};
}

void GroupingModel::resetInternalData()
{
    QAbstractProxyModel::resetInternalData();

    auto source = sourceModel();

    m_rolesInitialized = false;
    m_roleNames.clear();

    m_entries.clear();
    m_submodels.clear();

    if (source == nullptr)
        return;

    if (source->rowCount() > 0) {
        initRoles();
        initSubmodelRole();

        if (m_groupingRole)
            init();
    }
}

void GroupingModel::init()
{
    auto count = sourceModel()->rowCount();

    Q_ASSERT(m_groupingRole.has_value());

    QVariant previousVal;

    // from/to pair for every group
    std::vector<std::pair<int, int>> pairs;

    m_entries.reserve(count);
    int submodel = -1;

    for (int i = 0; i < count; i++) {
        auto val = sourceModel()->data(sourceModel()->index(i, 0), *m_groupingRole);

        if (val != previousVal || pairs.empty()) {
            submodel++;
            pairs.emplace_back(i, i);
        } else {
            pairs.back().second++;
        }

        m_entries.push_back({submodel, pairs.back().second - pairs.back().first, i});

        previousVal = val;
    }

    m_submodels.reserve(pairs.size());
    std::transform(pairs.cbegin(), pairs.cend(), std::back_inserter(m_submodels),
                   [this] (auto& entry) {
        return std::make_unique<RangeModel>(sourceModel(), m_entries, entry.first, entry.second);
    });
}

void GroupingModel::initRoles()
{
    auto roleNames = sourceModel()->roleNames();
    auto roles = roleNames.keys();
    auto maxIt = std::max_element(roles.cbegin(), roles.cend());

    m_submodelRole = maxIt == roles.cend() ? 0 : *maxIt + 1;
    roleNames.insert(m_submodelRole, m_submodelRoleName.toUtf8());

    m_roleNames = std::move(roleNames);
    m_rolesInitialized = true;
}

void GroupingModel::initSubmodelRole()
{
    auto groupingRole = m_roleNames.keys(m_groupingRoleName.toUtf8());

    if (groupingRole.size())
        m_groupingRole = groupingRole.first();
    else
        m_groupingRole.reset();
}

void GroupingModel::connectSignals(QAbstractItemModel* model)
{
    connect(model, &QAbstractItemModel::rowsInserted, this,
            [this, model](const QModelIndex &parent, int first, int last) {

        if (!m_rolesInitialized) {
            initRoles();
            initSubmodelRole(); // check order
        }

        auto insertCount = last - first + 1;

        std::optional<QVariant> previousGroupingValue;

        if (first - 1 >= 0)
            previousGroupingValue = ::data(model, first - 1, *m_groupingRole);

        std::optional<QVariant> nextGroupingValue;

        if (last + 1 < m_entries.size() + insertCount)
            nextGroupingValue = ::data(model, last + 1, *m_groupingRole);

        int currentFirst = first;
        int currentLast = last;

        int appendToPrevious = 0;
        int appendToNext = 0;

        // count data belonging to the previous group
        while (previousGroupingValue
               && currentFirst <= currentLast
               && ::data(model, currentFirst, *m_groupingRole) == *previousGroupingValue) {
            currentFirst++;
            appendToPrevious++;
        }

        // count data belonging to the following group
        while (nextGroupingValue
               && currentLast >= currentFirst
               && ::data(model, currentLast, *m_groupingRole) == *nextGroupingValue) {
            currentLast--;
            appendToNext++;
        }

        int toNewGroups = insertCount - appendToPrevious - appendToNext;
        int toRemove = 0;

        // shift indexes to indicate old items for rowsAboutToBe* signals
        for (auto i = first; i < m_entries.size(); i++)
            m_entries[i].sourceIndex += last - first + 1;

        if (toNewGroups > 0 && previousGroupingValue && nextGroupingValue
                && previousGroupingValue == nextGroupingValue) {

            int submodelIndex = m_entries[first - 1].submodel;
            RangeModel* submodel = m_submodels[submodelIndex].get();

            toRemove = submodel->rowCount() - m_entries[first - 1].submodelIndex - 1;

            submodel->beginRemoveRows({}, m_entries[first - 1].submodelIndex + 1,
                    submodel->rowCount() - 1);
            submodel->to() -= toRemove;
            submodel->endRemoveRows();

            toNewGroups += toRemove + appendToNext;
            appendToNext = 0;
        }

        RangeModel* previousModel = nullptr;
        RangeModel* nextModel = nullptr;

        if (appendToPrevious) {
            const Entry& entry = m_entries[first - 1];
            int submodel = entry.submodel;
            int offset = entry.submodelIndex + 1;

            previousModel = m_submodels[submodel].get();
            previousModel->beginInsertRows({}, offset, appendToPrevious + offset - 1);
        }

        // prepare new entries

        QVariant previousVal;
        std::vector<std::pair<int, int>> pairs;

        int baseline = first + appendToPrevious;
        int submodel = -1;

        for (int i = baseline; i < baseline + toNewGroups; i++) {

            Q_ASSERT(m_groupingRole);

            auto val = sourceModel()->data(sourceModel()->index(i, 0), *m_groupingRole);

            if (val != previousVal || pairs.empty()) {
                submodel++;
                pairs.emplace_back(i, i);
            } else {
                pairs.back().second++;
            }

            previousVal = val;
        }

        std::vector<std::unique_ptr<RangeModel>> newSubmodels;

        std::transform(pairs.cbegin(), pairs.cend(), std::back_inserter(newSubmodels),
                       [this] (auto& entry) {
            return std::make_unique<RangeModel>(sourceModel(), m_entries, entry.first, entry.second);
        });

        if (newSubmodels.size()) {
            int offset = first == 0 ? 0 : m_entries[first - 1].submodel + 1;
            beginInsertRows({}, offset, offset + newSubmodels.size() - 1);
        }

        if (appendToNext) {
            Q_ASSERT(first < m_entries.size());

            int submodel = m_entries[first].submodel;

            Q_ASSERT(submodel < m_submodels.size());

            nextModel = m_submodels[submodel].get();
            nextModel->beginInsertRows({}, 0, appendToNext - 1);
        }

        // ADJUST STRUCTURES

        if (appendToPrevious) {
            previousModel->to() += appendToPrevious;

            const Entry& entry = m_entries[first - 1];
            int submodel = entry.submodel;

            for (int i = submodel + 1; i < m_submodels.size(); i++)
                m_submodels[i]->shift(appendToPrevious);
        }

        if (newSubmodels.size()) {
            int offset = first == 0 ? 0 : m_entries[first - 1].submodel + 1;

            m_submodels.insert(m_submodels.begin() + offset,
                               std::make_move_iterator(newSubmodels.begin()),
                               std::make_move_iterator(newSubmodels.end()));

            for (int i = offset + newSubmodels.size(); i < m_submodels.size(); i++)
                m_submodels[i]->shift(toNewGroups - toRemove);
        }

        if (appendToNext) {
            nextModel->to() += appendToNext;

            int submodel = m_entries[first].submodel + newSubmodels.size();

            for (int i = submodel + 1; i < m_submodels.size(); i++)
                m_submodels[i]->shift(appendToNext);
        }

        m_entries.resize(m_entries.size() + insertCount);
        int totalCounter = 0;

        for (std::size_t i = 0; i < m_submodels.size(); i++) {
            RangeModel* model = m_submodels[i].get();
            int count = model->rowCount();

            for (std::size_t j = 0; j < count; j++) {
                Entry& entry = m_entries[totalCounter];
                entry.submodel = i;
                entry.submodelIndex = j;
                entry.sourceIndex = totalCounter;

                totalCounter++;
            }
        }

        // EMIT SIGNALS
        if (previousModel)
            previousModel->endInsertRows();

        if (newSubmodels.size())
            endInsertRows();

        if (nextModel) {
            nextModel->endInsertRows();

            auto dataChangedIdx = index(m_entries[last].submodel, 0);
            auto roles = m_roleNames.keys();
            roles.removeOne(m_submodelRole);
            roles.removeOne(*m_groupingRole);

            emit dataChanged(dataChangedIdx, dataChangedIdx, roles.toVector());
        }
    });

    connect(model, &QAbstractItemModel::rowsAboutToBeRemoved, this,
            [this, model](const QModelIndex &parent, int first, int last) {
        int firstSubmodelToBeRemoved = -1;
        int lastSubmodelToBeRemoved = -1;

        bool mergeRequired = first > 0
                && last < m_entries.size() - 1
                && m_entries[first - 1].submodel != m_entries[last + 1].submodel
                && ::data(model, first - 1, *m_groupingRole)
                    == ::data(model, last + 1, *m_groupingRole);

        std::vector<std::tuple<RangeModel*, int, int>> removals;

        for (int i = first; i <= last;) {
            Entry& entry = m_entries[i];

            auto submodel = entry.submodel;
            auto submodelIndex = entry.submodelIndex;

            RangeModel* s = m_submodels[submodel].get();
            auto submodelCount = s->rowCount();

            int remaining = last - i + 1;

            if (submodelIndex == 0 && remaining >= submodelCount) {
                if (firstSubmodelToBeRemoved == -1) {
                    firstSubmodelToBeRemoved = submodel;
                    lastSubmodelToBeRemoved = submodel;
                } else {
                    lastSubmodelToBeRemoved++;
                }
            } else {
                int removeFrom = submodelIndex;
                int removeTo = std::min(removeFrom + remaining, submodelCount) - 1;
                int countToRemove = removeTo - removeFrom + 1;

                if (removeFrom == 0) {
                    if (!mergeRequired) {
                        s->beginRemoveRows({}, removeFrom, removeTo);
                        s->from() = s->from() + countToRemove;
                        s->endRemoveRows();
                    }
                } else {
                    s->beginRemoveRows({}, removeFrom, removeTo);
                    s->to() = s->to() - countToRemove;

                    Q_ASSERT(m_pendingRemovalSubmodel == nullptr);

                    // removing tail of the submodel
                    if (removeTo == submodelCount - 1)
                        s->endRemoveRows();
                    // removing from the middle, must be deferred to keep correct
                    // intermediate state
                    else
                        m_pendingRemovalSubmodel = s;
                }
            }

            i += submodelCount - submodelIndex;
        }

        auto mergeCount = 0;

        if (mergeRequired) {
            lastSubmodelToBeRemoved++;

            auto submodel = m_entries[first - 1].submodel;
            auto submodelToBeMerged = m_entries[last + 1].submodel;

            mergeCount = m_submodels[submodelToBeMerged]->rowCount()
                    - m_entries[last + 1].submodelIndex;
        }

        if (firstSubmodelToBeRemoved != -1) {
            beginRemoveRows({}, firstSubmodelToBeRemoved, lastSubmodelToBeRemoved);

            m_submodels.erase(m_submodels.begin() + firstSubmodelToBeRemoved,
                              m_submodels.begin() + lastSubmodelToBeRemoved + 1);

            endRemoveRows();
        }

        if (mergeRequired) {
            auto submodel = m_entries[first - 1].submodel;

            RangeModel* s = m_submodels[submodel].get();
            s->beginInsertRows({}, s->rowCount(), s->rowCount() + mergeCount - 1);
            s->to() = s->to() + mergeCount;

            Q_ASSERT(m_pendingMergeSubmodel == nullptr);
            m_pendingMergeSubmodel = s;
        }
    });

    connect(model, &QAbstractItemModel::rowsRemoved, this,
            [this, model](const QModelIndex &parent, int first, int last) {
        int newSize = m_entries.size() - (last - first + 1);
        m_entries.clear();
        m_entries.reserve(newSize);

        int sourceIndex = 0;

        for (int i = 0; i < m_submodels.size(); i++) {
            auto s = m_submodels[i].get();
            auto count = s->rowCount();

            s->from() = sourceIndex;
            s->to() = sourceIndex + count - 1;

            for (int j = 0; j < count; j++)
                m_entries.push_back({i, j, sourceIndex++});
        }

        if (m_pendingMergeSubmodel) {
            m_pendingMergeSubmodel->endInsertRows();
            m_pendingMergeSubmodel = nullptr;
        }

        if (m_pendingRemovalSubmodel) {
            m_pendingRemovalSubmodel->endRemoveRows();
            m_pendingRemovalSubmodel = nullptr;
        }

        Q_ASSERT(m_entries.size() == newSize);
    });

    connect(model, &QAbstractItemModel::dataChanged, this, [this, model] (
            const QModelIndex& topLeft, const QModelIndex& bottomRight,
            const QVector<int>& roles) {

        if (!topLeft.isValid() || !bottomRight.isValid())
            return;

        auto sourceFirst = topLeft.row();
        auto sourceLast = bottomRight.row();

        auto destFirst = m_entries.at(sourceFirst).submodel;
        auto destLast = m_entries.at(sourceLast).submodel;

        // internal models
        int changeSize = sourceLast - sourceFirst + 1;
        int offset = m_entries.at(sourceFirst).submodelIndex;

        for (auto i = destFirst; i <= destLast; i++) {
            auto submodel = m_submodels[i].get();
            auto sumodelChangeSize = std::min(changeSize,
                                              submodel->rowCount() - offset);

            emit submodel->dataChanged(submodel->index(offset),
                                       submodel->index(offset + sumodelChangeSize - 1),
                                       roles);

            changeSize -= sumodelChangeSize;
            offset = 0;
        }

        // external model
        if (m_entries.at(sourceFirst).submodelIndex > 0)
            destFirst++;

        if (destLast < destFirst)
            return;

        const QVector<int>& rolesAligned = roles.isEmpty()
                ? model->roleNames().keys().toVector()
                : roles;

        emit this->dataChanged(this->index(destFirst), this->index(destLast),
                               rolesAligned);
    });

    connect(model, &QAbstractItemModel::modelAboutToBeReset, this, [this] {
        this->beginResetModel();
    });

    connect(model, &QAbstractItemModel::modelReset, this, [this] {
        this->endResetModel();
    });

    connect(model, &QAbstractItemModel::layoutAboutToBeChanged, this, [this] {
        this->beginResetModel();
    });

    connect(model, &QAbstractItemModel::layoutChanged, this, [this] {
        this->endResetModel();
    });
}

#include "groupingmodel.moc"
