#include "StatusQ/rolesrenamingmodel.h"

#include <QDebug>

RoleRename::RoleRename(QObject* parent)
    : QObject{parent}
{
}

void RoleRename::setFrom(const QString& from)
{
    if (m_from == from)
        return;

    if (!m_from.isEmpty()) {
        qWarning() << "RoleRename: property \"from\" is intended to be "
                      "initialized once and not changed!";
        return;
    }

    m_from = from;
    emit fromChanged();
}

const QString& RoleRename::from() const
{
    return m_from;
}

void RoleRename::setTo(const QString& to)
{
    if (m_to == to)
        return;

    if (!m_to.isEmpty()) {
        qWarning() << "RoleRename: property \"to\" is intended to be "
                      "initialized once and not changed!";
        return;
    }

    m_to = to;
    emit toChanged();
}

const QString& RoleRename::to() const
{
    return m_to;
}

RolesRenamingModel::RolesRenamingModel(QObject* parent)
    : QIdentityProxyModel{parent}
{
}

QQmlListProperty<RoleRename> RolesRenamingModel::mapping()
{
    QQmlListProperty<RoleRename> list(this, &m_mapping);

    list.replace = nullptr;
    list.clear = nullptr;
    list.removeLast = nullptr;

    list.append = [](auto listProperty, auto element) {
        RolesRenamingModel* model = qobject_cast<RolesRenamingModel*>(
                    listProperty->object);

        if (model->m_rolesFetched) {
            qWarning() << "RolesRenamingModel: role names mapping cannot be "
                          "modified after fetching role names!";
            return;
        }

        model->m_mapping.append(element);
    };

    return list;
}

QHash<int, QByteArray> RolesRenamingModel::roleNames() const
{
    const auto roles = sourceModel() ? sourceModel()->roleNames() : QHash<int, QByteArray>{};

    if (roles.isEmpty())
        return roles;

    QHash<QString, RoleRename*> renameMap;

    for (const auto rename : m_mapping)
        renameMap.insert(rename->from(), rename);

    QHash<int, QByteArray> remapped;
    remapped.reserve(roles.size());

    QSet<QByteArray> roleNamesSet;
    roleNamesSet.reserve(roles.size());

    for (auto i = roles.cbegin(), end = roles.cend(); i != end; ++i) {
        RoleRename* rename = renameMap.take(i.value());
        QByteArray roleName = rename ? rename->to().toUtf8() : i.value();

        remapped.insert(i.key(), roleName);
        roleNamesSet.insert(roleName);
    }

    if (roles.size() != roleNamesSet.size()) {
        qWarning() << "RolesRenamingModel: model cannot contain duplicated "
                      "role names!";
        return {};
    }

    if (!renameMap.isEmpty()) {
        qWarning().nospace()
                << "RolesRenamingModel: specified source roles not found: "
                << renameMap.keys() << "!";
    }

    m_rolesFetched = true;
    return remapped;
}
