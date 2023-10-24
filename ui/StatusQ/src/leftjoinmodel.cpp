#include "StatusQ/leftjoinmodel.h"

#include <QDebug>

#include <algorithm>

LeftJoinModel::LeftJoinModel(QObject* parent)
    : QIdentityProxyModel{parent}
{
}

void LeftJoinModel::initializeIfReady()
{
    if (m_leftModel && m_rightModel && !m_joinRole.isEmpty()
            && !m_leftModel->roleNames().empty()
            && !m_rightModel->roleNames().empty())
        initialize();
}

void LeftJoinModel::initialize()
{
    auto leftRoleNames = m_leftModel->roleNames();
    auto rightRoleNames = m_rightModel->roleNames();

    if (leftRoleNames.isEmpty() || rightRoleNames.isEmpty()) {
        qWarning() << "Both left and right models have to contain some roles!";
        return;
    }

    auto leftModelJoinRoleList = leftRoleNames.keys(m_joinRole.toUtf8());
    auto rightModelJoinRoleList = rightRoleNames.keys(m_joinRole.toUtf8());

    if (leftModelJoinRoleList.size() != 1
            || rightModelJoinRoleList.size() != 1) {
        qWarning().noquote() << QString("Both left and right models have to "
                                        "contain join role %1!").arg(m_joinRole);
        return;
    }

    m_leftModelJoinRole = leftModelJoinRoleList.at(0);
    m_rightModelJoinRole = rightModelJoinRoleList.at(0);

    auto leftRoles = leftRoleNames.keys();
    auto maxLeftRole = std::max_element(leftRoles.cbegin(), leftRoles.cend());
    auto rightRolesOffset = *maxLeftRole + 1;
    auto roleNames = leftRoleNames;

    auto i = rightRoleNames.constBegin();
    while (i != rightRoleNames.constEnd()) {
        if (i.value() != m_joinRole) {
            auto roleWithOffset = i.key() + rightRolesOffset;
            roleNames.insert(roleWithOffset, i.value());
            m_joinedRoles.append(roleWithOffset);
        }
        ++i;
    }

    m_rightModelRolesOffset = rightRolesOffset;
    m_roleNames = roleNames;

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

        emit dataChanged(index(0, 0), index(rowCount() - 1, 0), rolesTranslated);
    });

    disconnect(m_leftModel, &QAbstractItemModel::rowsInserted,
               this, &LeftJoinModel::initializeIfReady);
    disconnect(m_rightModel, &QAbstractItemModel::rowsInserted,
               this, &LeftJoinModel::initializeIfReady);

    auto emitJoinedRolesChanged = [this] {
        emit dataChanged(index(0, 0), index(rowCount() - 1, 0), m_joinedRoles);
    };

    connect(m_rightModel, &QAbstractItemModel::rowsRemoved, this,
            emitJoinedRolesChanged);
    connect(m_rightModel, &QAbstractItemModel::rowsInserted, this,
            emitJoinedRolesChanged);
    connect(m_rightModel, &QAbstractItemModel::modelReset, this,
            emitJoinedRolesChanged);
    connect(m_rightModel, &QAbstractItemModel::layoutChanged, this,
            emitJoinedRolesChanged);

    connect(this, &QAbstractItemModel::dataChanged, this,
            [this](auto& topLeft, auto& bottomRight, auto& roles) {
        if (roles.contains(m_leftModelJoinRole))
            emit dataChanged(topLeft, bottomRight, m_joinedRoles);
    });

    QIdentityProxyModel::setSourceModel(m_leftModel);
}

QVariant LeftJoinModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid())
        return {};

    auto idx = m_leftModel->index(index.row(), index.column());

    if (role < m_rightModelRolesOffset)
        return m_leftModel->data(idx, role);

    if (m_rightModelDestroyed)
        return {};

    QVariant joinRoleLeftValue = m_leftModel->data(idx, m_leftModelJoinRole);

    if (m_lastUsedRightModelIndex.isValid()
            && m_rightModel->data(m_lastUsedRightModelIndex,
                                  m_rightModelJoinRole) == joinRoleLeftValue)
    {
        return m_rightModel->data(m_lastUsedRightModelIndex,
                                  role - m_rightModelRolesOffset);
    }

    int rightModelCount = m_rightModel->rowCount();

    for (int i = 0; i < rightModelCount; i++) {
        auto rightModelIdx =  m_rightModel->index(i, 0);
        auto rightJointRoleValue = m_rightModel->data(rightModelIdx,
                                                      m_rightModelJoinRole);

        if (joinRoleLeftValue == rightJointRoleValue) {
            m_lastUsedRightModelIndex = rightModelIdx;

            return m_rightModel->data(rightModelIdx,
                                      role - m_rightModelRolesOffset);
        }
    }

    return {};
}

void LeftJoinModel::setLeftModel(QAbstractItemModel* model)
{
    if (m_leftModel == model)
        return;

    if (m_leftModel != nullptr || m_leftModelDestroyed) {
        qWarning("Changing left model is not supported!");
        return;
    }

    m_leftModel = model;

    // Some models may have roles undefined until first row is inserted,
    // like ListModel, therefore in such cases initialization must be deferred
    // until first insertion.
    connect(m_leftModel, &QAbstractItemModel::rowsInserted,
            this, &LeftJoinModel::initializeIfReady);

    connect(m_leftModel, &QObject::destroyed, this, [this] {
        this->m_leftModel = nullptr;
        this->m_leftModelDestroyed = true;
    });

    emit leftModelChanged();

    initializeIfReady();
}

QAbstractItemModel* LeftJoinModel::leftModel() const
{
    return m_leftModel;
}

void LeftJoinModel::setRightModel(QAbstractItemModel* model)
{
    if (m_rightModel == model)
        return;

    if (m_rightModel != nullptr || m_rightModelDestroyed) {
        qWarning("Changing right model is not supported!");
        return;
    }

    m_rightModel = model;

    // see: LeftJoinModel::setLeftModel
    connect(m_rightModel, &QAbstractItemModel::rowsInserted,
            this, &LeftJoinModel::initializeIfReady);

    connect(m_rightModel, &QObject::destroyed, this, [this] {
        this->m_rightModel = nullptr;
        this->m_rightModelDestroyed = true;
    });

    emit rightModelChanged();

    initializeIfReady();
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

    initializeIfReady();
}

const QString& LeftJoinModel::joinRole() const
{
    return m_joinRole;
}

void LeftJoinModel::setSourceModel(QAbstractItemModel* newSourceModel)
{
    qWarning() << "Source model is not intended to be set directly on this model."
                  " Use setLeftModel and setRightModel instead!";
}

QHash<int, QByteArray> LeftJoinModel::roleNames() const
{
    return m_roleNames;
}
