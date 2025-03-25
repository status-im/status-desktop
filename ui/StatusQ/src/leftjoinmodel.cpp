#include "StatusQ/leftjoinmodel.h"

#include <QDebug>

#include <algorithm>

LeftJoinModel::LeftJoinModel(QObject* parent)
    : QAbstractListModel{parent}
{
}

void LeftJoinModel::initializeIfReady(bool reset)
{
    if (m_leftModel && m_rightModel && !m_joinRole.isEmpty()
            && !m_leftModel->roleNames().empty()
            && !m_rightModel->roleNames().empty())
        initialize(reset);
}

void LeftJoinModel::initialize(bool reset)
{
    auto leftRoleNames = m_leftModel->roleNames();
    auto rightRoleNames = m_rightModel->roleNames();

    auto leftNames = leftRoleNames.values();
    QByteArrayList rightNames;

    if (m_rolesToJoin.empty()) {
        rightNames = rightRoleNames.values();
    } else {
        QHash<int, QByteArray> tmpRightRoleNames;

        auto rolesToJoin = m_rolesToJoin;

        if (rolesToJoin.indexOf(m_joinRole) == -1)
            rolesToJoin << m_joinRole;

        for (auto& roleName : std::as_const(rolesToJoin)) {
            auto name = roleName.toUtf8();
            auto roles = rightRoleNames.keys(name);

            if (roles.empty()) {
                qWarning().noquote()
                        << QStringLiteral("Role to join %1 not found in the right model!")
                           .arg(roleName);
                return;
            }

            rightNames << name;
            tmpRightRoleNames.insert(roles.front(), name);
        }

        rightRoleNames = tmpRightRoleNames;
    }

    QSet<QByteArray> leftNamesSet(leftNames.cbegin(), leftNames.cend());
    QSet<QByteArray> rightNamesSet(rightNames.cbegin(), rightNames.cend());

    if (leftNames.size() != leftNamesSet.size()
            || rightNames.size() != rightNamesSet.size()) {
        qWarning() << "Each of the source models must have unique role names!";
        return;
    }

    auto namesIntersection = leftNamesSet.intersect(rightNamesSet);
    auto hasCommonJoinRole = namesIntersection.remove(m_joinRole.toUtf8());

    if (!hasCommonJoinRole) {
        qWarning().noquote() << QString("Both left and right models have to "
                                        "contain join role %1!").arg(m_joinRole);
        return;
    }

    if (!namesIntersection.isEmpty()) {
        qWarning().nospace() << "Source models contain conflicting model names: "
                             << QList(namesIntersection.cbegin(),
                                      namesIntersection.cend()).join()
                             << "!";
        return;
    }

    if (reset)
        beginResetModel();

    auto leftRoles = leftRoleNames.keys();
    auto maxLeftRole = std::max_element(leftRoles.cbegin(), leftRoles.cend());
    auto rightRolesOffset = *maxLeftRole + 1;
    auto roleNames = leftRoleNames;
    QVector<int> joinedRoles;

    auto i = rightRoleNames.constBegin();
    while (i != rightRoleNames.constEnd()) {
        if (i.value() != m_joinRole) {
            auto roleWithOffset = i.key() + rightRolesOffset;
            roleNames.insert(roleWithOffset, i.value());
            joinedRoles.append(roleWithOffset);
        }
        ++i;
    }

    m_roleNames = std::move(roleNames);
    m_joinedRoles = std::move(joinedRoles);
    m_leftModelJoinRole = leftRoleNames.key(m_joinRole.toUtf8());
    m_rightModelJoinRole = rightRoleNames.key(m_joinRole.toUtf8());
    m_rightModelRolesOffset = rightRolesOffset;

    m_leftRoleNames = std::move(leftRoleNames);
    m_rightRoleNames = std::move(rightRoleNames);

    disconnect(m_leftModel, nullptr, this, nullptr);
    disconnect(m_rightModel, nullptr, this, nullptr);

    connectRightModelSignals();
    connectLeftModelSignals();

    m_initialized = true;

    if (reset)
        endResetModel();
}

void LeftJoinModel::connectLeftModelSignals()
{
    connect(m_leftModel, &QAbstractItemModel::dataChanged, this,
            [this](auto& topLeft, auto& bottomRight, auto& roles) {

        auto tl = index(topLeft.row());
        auto br = index(bottomRight.row());

        if (roles.contains(m_leftModelJoinRole))
            emit dataChanged(tl, br, m_joinedRoles + roles);
        else
            emit dataChanged(tl, br, roles);
    });

    connect(m_leftModel, &QAbstractItemModel::rowsAboutToBeInserted,
            this, [this](const QModelIndex& parent, int first, int last) {
        if (!parent.isValid())
            beginInsertRows({}, first, last);
    });

    connect(m_leftModel, &QAbstractItemModel::rowsInserted,
            this, [this](const QModelIndex& parent, int first, int last) {
        if (!parent.isValid())
            endInsertRows();
    });

    connect(m_leftModel, &QAbstractItemModel::rowsAboutToBeRemoved,
            this, [this](const QModelIndex& parent, int first, int last) {
        if (!parent.isValid())
            beginRemoveRows({}, first, last);
    });

    connect(m_leftModel, &QAbstractItemModel::rowsRemoved,
            this, [this](const QModelIndex& parent, int first, int last) {
        if (!parent.isValid())
            endRemoveRows();
    });

    connect(m_leftModel, &QAbstractItemModel::rowsAboutToBeMoved,
            this, [this](const QModelIndex &sourceParent, int sourceStart,
                int sourceEnd, const QModelIndex &destinationParent, int destinationRow) {
        if (!sourceParent.isValid() && !destinationParent.isValid())
            beginMoveRows({}, sourceStart, sourceEnd, {}, destinationRow);
    });

    connect(m_leftModel, &QAbstractItemModel::rowsMoved,
            this, [this](const QModelIndex &sourceParent, int sourceStart,
                int sourceEnd, const QModelIndex &destinationParent, int destinationRow) {
        if (!sourceParent.isValid() && !destinationParent.isValid())
            endMoveRows();
    });

    connect(m_leftModel, &QAbstractItemModel::layoutAboutToBeChanged, this, [this]() {
        emit layoutAboutToBeChanged();

        const auto persistentIndexes = persistentIndexList();

        for (const QModelIndex& persistentIndex: persistentIndexes) {
            m_proxyIndexes << persistentIndex;
            Q_ASSERT(persistentIndex.isValid());
            const auto srcIndex = m_leftModel->index(
                        persistentIndex.row(),
                        persistentIndex.column());

            Q_ASSERT(srcIndex.isValid());
            m_layoutChangePersistentIndexes << srcIndex;
        }
    });

    connect(m_leftModel, &QAbstractItemModel::layoutChanged, this, [this]() {
        for (int i = 0; i < m_proxyIndexes.size(); ++i) {
            auto p = m_layoutChangePersistentIndexes.at(i);
            changePersistentIndex(m_proxyIndexes.at(i), index(
                                      p.row(), p.column(), p.parent()));
        }

        m_layoutChangePersistentIndexes.clear();
        m_proxyIndexes.clear();

        emit layoutChanged();
    });

    connect(m_leftModel, &QAbstractItemModel::modelAboutToBeReset, this,
            &LeftJoinModel::beginResetModel);

    connect(m_leftModel, &QAbstractItemModel::modelReset, this,
            &LeftJoinModel::endResetModel);
}

void LeftJoinModel::connectRightModelSignals()
{
    connect(m_rightModel, &QAbstractItemModel::dataChanged, this,
            [this](auto& topLeft, auto& bottomRight, auto& roles) {
        QVector<int> rolesTranslated;

        if (roles.contains(m_rightModelJoinRole)) {
            rolesTranslated = m_joinedRoles;
        } else {
            rolesTranslated = roles;

            for (auto& role : rolesTranslated)
                role += m_rightModelRolesOffset;
        }

        emit dataChanged(index(0), index(rowCount() - 1), rolesTranslated);
    });

    auto emitJoinedRolesChanged = [this] {
        emit dataChanged(index(0), index(rowCount() - 1), m_joinedRoles);
    };

    connect(m_rightModel, &QAbstractItemModel::rowsRemoved, this,
            emitJoinedRolesChanged);
    connect(m_rightModel, &QAbstractItemModel::rowsInserted, this,
            emitJoinedRolesChanged);
    connect(m_rightModel, &QAbstractItemModel::modelReset, this,
            emitJoinedRolesChanged);
}

QVariant LeftJoinModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || m_leftModel == nullptr)
        return {};

    auto idx = m_leftModel->index(index.row(), index.column());

    if (role < m_rightModelRolesOffset)
        return m_leftModel->data(idx, role);

    if (m_rightModel == nullptr)
        return {};

    auto joinRoleLeftValue = m_leftModel->data(idx, m_leftModelJoinRole);

    if (m_lastUsedRightModelIndex.isValid()
            && m_rightModel->data(m_lastUsedRightModelIndex,
                                  m_rightModelJoinRole) == joinRoleLeftValue) {
        return m_rightModel->data(m_lastUsedRightModelIndex,
                                  role - m_rightModelRolesOffset);
    }

    QModelIndexList match = m_rightModel->match(
                m_rightModel->index(0, 0), m_rightModelJoinRole,
                joinRoleLeftValue, 1, Qt::MatchExactly);

    if (match.isEmpty())
        return {};

    m_lastUsedRightModelIndex = match.constFirst();
    return m_lastUsedRightModelIndex.data(role - m_rightModelRolesOffset);
}

void LeftJoinModel::classBegin()
{
}

void LeftJoinModel::componentComplete()
{
    if (!m_initialized)
        initializeIfReady(false);
}

void LeftJoinModel::setLeftModel(QAbstractItemModel* model)
{
    if (m_leftModel == model)
        return;

    if (m_leftModel)
        disconnect(m_leftModel, nullptr, this, nullptr);

    bool was_initialized = m_initialized;

    if (was_initialized)
        beginResetModel();

    m_initialized = false;
    m_leftModel = model;

    // Some models may have roles undefined until first row is inserted,
    // like ListModel, therefore in such cases initialization must be deferred
    // until first insertion.
    connect(m_leftModel, &QAbstractItemModel::rowsInserted,
            this, [this]() { initializeIfReady(true); });

    emit leftModelChanged();

    initializeIfReady(!was_initialized);

    if (was_initialized)
        endResetModel();
}

QAbstractItemModel* LeftJoinModel::leftModel() const
{
    return m_leftModel;
}

void LeftJoinModel::setRightModel(QAbstractItemModel* model)
{
    if (m_rightModel == model)
        return;

    if (m_rightModel)
        disconnect(m_rightModel, nullptr, this, nullptr);

    if (m_initialized &&
            (model == nullptr || model->roleNames() == m_rightRoleNames)) {

        m_rightModel = model;
        emit rightModelChanged();

        auto count = rowCount();

        if (count > 0)
            emit dataChanged(index(0), index(count - 1), m_joinedRoles);

        return;
    }

    bool was_initialized = m_initialized;

    if (was_initialized)
        beginResetModel();

    m_initialized = false;
    m_rightModel = model;

    // see: LeftJoinModel::setLeftModel
    connect(m_rightModel, &QAbstractItemModel::rowsInserted,
            this, [this]() { initializeIfReady(true); });

    emit rightModelChanged();

    initializeIfReady(!was_initialized);

    if (was_initialized)
        endResetModel();
}

QAbstractItemModel* LeftJoinModel::rightModel() const
{
    return m_rightModel;
}

void LeftJoinModel::setJoinRole(const QString& joinRole)
{
    if (m_joinRole.isEmpty() && joinRole.isEmpty())
        return;

    if (!m_joinRole.isEmpty()) {
        qWarning("Changing join role is not supported!");
        return;
    }

    m_joinRole = joinRole;

    emit joinRoleChanged();

    initializeIfReady(true);
}

const QString& LeftJoinModel::joinRole() const
{
    return m_joinRole;
}

void LeftJoinModel::setRolesToJoin(const QStringList& roles)
{
    if (m_rolesToJoin == roles)
        return;

    m_rolesToJoin = roles;
    emit rolesToJoinChanged();
}

const QStringList &LeftJoinModel::rolesToJoin() const
{
    return m_rolesToJoin;
}

int LeftJoinModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_leftModel == nullptr || !m_initialized
            ? 0 : m_leftModel->rowCount();
}

QHash<int, QByteArray> LeftJoinModel::roleNames() const
{
    return m_roleNames;
}
