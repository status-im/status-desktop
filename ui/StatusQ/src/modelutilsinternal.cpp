#include "StatusQ/modelutilsinternal.h"

#include <QAbstractItemModel>

ModelUtilsInternal::ModelUtilsInternal(QObject* parent)
    : QObject(parent)
{
}

QStringList ModelUtilsInternal::roleNames(QAbstractItemModel *model) const
{
    if (model == nullptr)
        return {};

    QHash<int, QByteArray> roles = model->roleNames();

    QStringList strings;
    strings.reserve(roles.size());

    for (auto it = roles.begin(); it != roles.end(); ++it)
        strings << QString::fromUtf8(it.value());

    return strings;
}


int ModelUtilsInternal::roleByName(QAbstractItemModel* model,
                                   const QString &roleName) const
{
    if (model == nullptr)
        return -1;

    return model->roleNames().key(roleName.toUtf8(), -1);
}

QVariantMap ModelUtilsInternal::get(QAbstractItemModel *model, int row) const
{
    QVariantMap map;

    if (model == nullptr)
        return map;

    QModelIndex modelIndex = model->index(row, 0);
    QHash<int, QByteArray> roles = model->roleNames();

    for (auto it = roles.begin(); it != roles.end(); ++it)
        map.insert(it.value(), model->data(modelIndex, it.key()));

    return map;
}

QVariant ModelUtilsInternal::get(QAbstractItemModel *model,
                                 int row, const QString &roleName) const
{
    return model->data(model->index(row, 0), roleByName(model, roleName));
}
