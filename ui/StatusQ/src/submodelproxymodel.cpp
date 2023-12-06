#include "StatusQ/submodelproxymodel.h"

#include <QDebug>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>

SubmodelProxyModel::SubmodelProxyModel(QObject* parent)
    : QIdentityProxyModel{parent}
{
}

QVariant SubmodelProxyModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid))
        return {};

    if (m_initialized && m_delegateModel && role == m_submodelRole) {
        auto submodel = QIdentityProxyModel::data(index, role);

        auto creationContext = m_delegateModel->creationContext();
        auto parentContext = creationContext
                ? creationContext : m_delegateModel->engine()->rootContext();

        auto context = new QQmlContext(parentContext, parentContext);
        context->setContextProperty(QStringLiteral("submodel"), submodel);

        QObject* instance = m_delegateModel->create(context);
        QQmlEngine::setObjectOwnership(instance, QQmlEngine::JavaScriptOwnership);

        return QVariant::fromValue(instance);
    }

    return QIdentityProxyModel::data(index, role);
}

void SubmodelProxyModel::setSourceModel(QAbstractItemModel* model)
{
    if (sourceModel() != nullptr || m_sourceModelDeleted) {
        qWarning("Changing source model is not supported!");
        return;
    }

    // Workaround for QTBUG-57971
    if (model && model->roleNames().isEmpty())
        connect(model, &QAbstractItemModel::rowsInserted,
                this, &SubmodelProxyModel::initRoles);

    connect(model, &QObject::destroyed, this, [this] {
        this->m_sourceModelDeleted = true;
    });

    QIdentityProxyModel::setSourceModel(model);
    initializeIfReady();
}

QQmlComponent* SubmodelProxyModel::delegateModel() const
{
    return m_delegateModel;
}

void SubmodelProxyModel::setDelegateModel(QQmlComponent* delegateModel)
{
    if (m_delegateModel == delegateModel)
        return;

    if (m_delegateModel)
        disconnect(delegateModel, &QObject::destroyed,
                   this, &SubmodelProxyModel::onDelegateChanged);

    if (delegateModel)
        connect(delegateModel, &QObject::destroyed,
                this, &SubmodelProxyModel::onDelegateChanged);

    m_delegateModel = delegateModel;

    onDelegateChanged();
}

const QString& SubmodelProxyModel::submodelRoleName() const
{
    return m_submodelRoleName;
}

void SubmodelProxyModel::setSubmodelRoleName(const QString& sumodelRoleName)
{
    if (m_submodelRoleName.isEmpty() && sumodelRoleName.isEmpty())
        return;

    if (!m_submodelRoleName.isEmpty()) {
        qWarning("Changing submodel role name is not supported!");
        return;
    }

    m_submodelRoleName = sumodelRoleName;
    emit submodelRoleNameChanged();

    initializeIfReady();
}

void SubmodelProxyModel::initializeIfReady()
{
    if (!m_submodelRoleName.isEmpty() && sourceModel()
            && !roleNames().empty())
        initialize();
}

void SubmodelProxyModel::initialize()
{
    auto roles = roleNames();
    auto keys = roles.keys(m_submodelRoleName.toUtf8());
    auto keysCount = keys.size();

    if (keysCount == 1) {
        m_initialized = true;
        m_submodelRole = keys.first();
    } else if (keysCount == 0){
        qWarning() << "Submodel role not found!";
    } else {
        qWarning() << "Malformed source model - multiple roles found for given "
                      "submodel role name!";
    }
}

void SubmodelProxyModel::initRoles()
{
    disconnect(sourceModel(), &QAbstractItemModel::rowsInserted,
            this, &SubmodelProxyModel::initRoles);

    resetInternalData();
    initializeIfReady();
}

void SubmodelProxyModel::onDelegateChanged()
{
    emit delegateModelChanged();

    if (m_initialized && rowCount() && columnCount()) {
        emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1),
                         { m_submodelRole });
    }
}

