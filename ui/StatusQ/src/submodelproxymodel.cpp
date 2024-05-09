#include "StatusQ/submodelproxymodel.h"

#include <QDebug>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>

#include <memory>

namespace {
    constexpr const auto roleSuffix = "Role";

    void emptyMessageHandler(QtMsgType type, const QMessageLogContext& context,
                             const QString& msg)
    {
        Q_UNUSED(type)
        Q_UNUSED(context)
        Q_UNUSED(msg)
    }
}

SubmodelProxyModel::SubmodelProxyModel(QObject* parent)
    : QIdentityProxyModel{parent}
{
}

QVariant SubmodelProxyModel::data(const QModelIndex& index, int role) const
{
    static constexpr auto attachementPropertyName = "_attachement";

    if (!checkIndex(index, CheckIndexOption::IndexIsValid))
        return {};

    if (m_delegateModel && m_submodelRole && role == m_submodelRole) {
        auto submodel = QIdentityProxyModel::data(index, role);

        QObject* submodelObj = submodel.value<QObject*>();

        if (submodelObj == nullptr) {
            qWarning("Submodel must be a QObject-based type!");
            return submodel;
        }

        QVariant attachement = submodelObj->property(attachementPropertyName);

        if (attachement.isValid())
            return attachement;

        // Make sure that wrapper is destroyed before it receives signal related
        // to submodel's destruction. Otherwise injected context property may
        // be cleared causing warnings related to accessing null from qml.
        connect(submodelObj, &QObject::destroyed, this, [](auto obj) {
            QVariant attachement = obj->property(attachementPropertyName);

            if (attachement.isValid())
                delete attachement.value<QObject*>();
        });

        auto creationContext = m_delegateModel->creationContext();
        auto parentContext = creationContext
                ? creationContext : m_delegateModel->engine()->rootContext();

        auto context = new QQmlContext(parentContext, submodelObj);
        context->setContextProperty(QStringLiteral("submodel"), submodel);

        QObject* instance = m_delegateModel->create(context);
        instance->setParent(submodelObj);

        QVariant wrappedInstance = QVariant::fromValue(instance);

        if (m_additionalRolesMap.size()) {
            QObject* connector = m_connector->createWithInitialProperties(
                        { { "target", QVariant::fromValue(instance) } });
            connector->setParent(instance);

            connect(connector, SIGNAL(customRoleChanged(QObject*,int)),
                    this, SLOT(onCustomRoleChanged(QObject*,int)));
        }

        submodelObj->setProperty(attachementPropertyName, wrappedInstance);

        return wrappedInstance;
    }

    if (m_submodelRole && role >= m_additionalRolesOffset
            && role < m_additionalRolesOffset + m_additionalRolesMap.size())
    {
        auto submodel = data(index, *m_submodelRole);

        auto submodelObj = submodel.value<QObject*>();

        if (submodelObj == nullptr) {
            qWarning("Submodel must be a QObject-based type!");
            return {};
        }

        return submodelObj->property(m_roleNames[role] + roleSuffix);
    }

    return QIdentityProxyModel::data(index, role);
}

void SubmodelProxyModel::setSourceModel(QAbstractItemModel* model)
{
    if (sourceModel() != nullptr || m_sourceModelDeleted) {
        qWarning("Changing source model is not supported!");
        return;
    }

    if (sourceModel() == model)
        return;

    // Workaround for QTBUG-57971
    if (model->roleNames().isEmpty())
        connect(model, &QAbstractItemModel::rowsInserted,
                this, &SubmodelProxyModel::initRoles);

    connect(model, &QObject::destroyed, this, [this] {
        this->m_sourceModelDeleted = true;
    });

    if (m_delegateModel)
        m_additionalRoles = fetchAdditionalRoles(m_delegateModel);

    QIdentityProxyModel::setSourceModel(model);
}

QHash<int, QByteArray> SubmodelProxyModel::roleNames() const
{
    return m_roleNames.isEmpty() && sourceModel()
            ? sourceModel()->roleNames() : m_roleNames;;
}

QQmlComponent* SubmodelProxyModel::delegateModel() const
{
    return m_delegateModel;
}

void SubmodelProxyModel::setDelegateModel(QQmlComponent* delegateModel)
{
    if (m_delegateModel != nullptr) {
        qWarning("Changing delegate model is not supported!");
        return;
    }

    if (m_delegateModel == delegateModel)
        return;

    if (sourceModel() != nullptr) {
        QStringList additionalRoles = fetchAdditionalRoles(delegateModel);

        if (m_additionalRoles == additionalRoles) {
            m_delegateModel = delegateModel;

            if (m_submodelRole && rowCount() && columnCount()) {
                emit dataChanged(index(0, 0),
                                 index(rowCount() - 1, columnCount() - 1),
                                 { *m_submodelRole });
            }
        } else {
            beginResetModel();
            m_delegateModel = delegateModel;
            m_additionalRoles = additionalRoles;
            endResetModel();
        }
    } else {
        m_delegateModel = delegateModel;
    }

    emit delegateModelChanged();
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

    if (sourceModel()) {
        m_submodelRole = findSubmodelRole(sourceModel()->roleNames(),
                                          sumodelRoleName);

        if (rowCount() && columnCount()) {
            emit dataChanged(index(0, 0),
                             index(rowCount() - 1, columnCount() - 1),
                             { *m_submodelRole });
        }
    }

    emit submodelRoleNameChanged();
}

void SubmodelProxyModel::resetInternalData()
{
    QIdentityProxyModel::resetInternalData();
    updateRoleNames();
}

void SubmodelProxyModel::onCustomRoleChanged(QObject* source, int role)
{
    if (!m_dataChangedQueued) {
        m_dataChangedQueued = true;
        QMetaObject::invokeMethod(this, "emitAllDataChanged", Qt::QueuedConnection);
    }
}

void SubmodelProxyModel::emitAllDataChanged()
{
    m_dataChangedQueued = false;
    auto count = rowCount();

    if (count == 0)
        return;

    QVector<int> roles(m_additionalRolesMap.cbegin(),
                       m_additionalRolesMap.cend());

    emit this->dataChanged(index(0, 0), index(count - 1, 0), roles);
}

void SubmodelProxyModel::initRoles()
{
    disconnect(sourceModel(), &QAbstractItemModel::rowsInserted,
            this, &SubmodelProxyModel::initRoles);

    resetInternalData();
}

void SubmodelProxyModel::updateRoleNames()
{
    if (sourceModel() == nullptr)
        return;

    auto roles = sourceModel()->roleNames();

    if (roles.empty())
        return;

    m_submodelRole = findSubmodelRole(roles, m_submodelRoleName);

    const auto keys = roles.keys();
    const auto maxElementIt = std::max_element(keys.begin(), keys.end());

    Q_ASSERT(maxElementIt != keys.end());

    auto maxRoleKey = *maxElementIt;
    m_additionalRolesOffset = maxRoleKey + 1;

    m_additionalRolesMap.clear();

    for (auto& additionalRole : qAsConst(m_additionalRoles)) {
        auto roleKey = ++maxRoleKey;

        roles.insert(roleKey, additionalRole.toUtf8());
        m_additionalRolesMap.insert(additionalRole, roleKey);
    }

    m_roleNames = roles;

    if (m_delegateModel == nullptr)
        return;

    m_connector = buildConnectorComponent(m_additionalRolesMap,
                                          m_delegateModel->engine(),
                                          m_delegateModel);
}

QStringList SubmodelProxyModel::fetchAdditionalRoles(
        QQmlComponent* delegateComponent)
{
    auto creationContext = delegateComponent->creationContext();
    auto parentContext = creationContext
            ? creationContext : delegateComponent->engine()->rootContext();

    auto context = std::make_unique<QQmlContext>(parentContext);

    // The delegate object is created in order to inspect properties. It may
    // be not properly initialized because of e.g. lack of context properties
    // containing submodel. To avoid warnings, they are muted by setting empty
    // message handler temporarily.
    QtMessageHandler originalHandler = qInstallMessageHandler(
                emptyMessageHandler);
    std::unique_ptr<QObject> instance(delegateComponent->create(context.get()));
    qInstallMessageHandler(originalHandler);

    const QMetaObject* meta = instance->metaObject();

    QStringList additionalRoles;

    for (auto i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
        const QLatin1String propertyName(meta->property(i).name());
        bool isRole = propertyName.endsWith(QLatin1String(roleSuffix));

        if (!isRole)
            continue;

        additionalRoles << propertyName.chopped(qstrlen(roleSuffix));
    }

    return additionalRoles;
}

QQmlComponent* SubmodelProxyModel::buildConnectorComponent(
        const QHash<QString, int>& additionalRoles, QQmlEngine* engine,
        QObject* parent)
{
    QString connectorCode = R"(
        import QtQml 2.15

        Connections {
            signal customRoleChanged(source: QtObject, role: int)
    )";

    for (auto i = additionalRoles.cbegin(); i != additionalRoles.cend(); ++i) {
        int role = i.value();

        auto upperCaseRole = i.key();
        upperCaseRole[0] = upperCaseRole[0].toUpper();

        connectorCode += QString(R"(
            function on%1RoleChanged() { customRoleChanged(target, %2) }
        )").arg(upperCaseRole).arg(role);
    }

    connectorCode += "}";

    auto connector = new QQmlComponent(engine, parent);
    connector->setData(connectorCode.toUtf8(), {});

    return connector;
}

std::optional<int> SubmodelProxyModel::findSubmodelRole(
        const QHash<int, QByteArray>& roleNames,
        const QString& submodelRoleName)
{
    if (roleNames.empty() || submodelRoleName.isEmpty())
        return {};

    auto submodelKeys = roleNames.keys(m_submodelRoleName.toUtf8());
    auto submodelKeysCount = submodelKeys.size();

    if (submodelKeysCount == 1) {
        return submodelKeys.first();
    } else if (submodelKeysCount == 0) {
        qWarning() << "Submodel role not found!";
        return {};
    } else {
        qWarning() << "Malformed source model - multiple roles found for given "
                      "submodel role name!";
        return {};
    }
}
