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

    const auto roles = model->roleNames();
    return {roles.cbegin(), roles.cend()};
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

    const auto modelIndex = model->index(row, 0);
    const auto roles = model->roleNames();

    for (auto it = roles.begin(); it != roles.end(); ++it)
        map.insert(it.value(), model->data(modelIndex, it.key()));

    return map;
}

QVariant ModelUtilsInternal::get(QAbstractItemModel *model,
                                 int row, const QString &roleName) const
{
    return model->data(model->index(row, 0), roleByName(model, roleName));
}

bool ModelUtilsInternal::contains(QAbstractItemModel* model,
                                  const QString& roleName,
                                  const QVariant& value,
                                  int mode) const
{
    if(!model) return false;

    Qt::MatchFlags flags = Qt::MatchFixedString; // Qt::CaseInsensitive by default
    if(mode == Qt::CaseSensitive) flags |= Qt::MatchCaseSensitive;
    const auto indexes = model->match(model->index(0, 0), roleByName(model, roleName), value, 1, flags);
    return !indexes.isEmpty();
}
