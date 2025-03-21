#include "StatusQ/modelutilsinternal.h"

#include <QAbstractItemModel>
#include <QDebug>


ModelUtilsInternal::ModelUtilsInternal(QObject* parent)
    : QObject(parent)
{
}

bool ModelUtilsInternal::isModel(const QVariant &obj) const
{
    if (!obj.canConvert<QObject*>())
        return false;

    return qobject_cast<QAbstractItemModel*>(obj.value<QObject*>()) != nullptr;
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
    if (auto role = roleByName(model, roleName); role != -1)
        return model->data(model->index(row, 0), role);

    return {};
}

QVariantList ModelUtilsInternal::getAll(QAbstractItemModel* model,
                                        const QString& roleName,
                                        const QString& filterRoleName,
                                        const QVariant& filterValue) const
{
    if (!model || filterValue.isNull())
        return {};

    const auto role = roleByName(model, roleName);
    if (role == -1)
        return {};

    const auto filterRole = roleByName(model, filterRoleName);
    if (filterRole == -1)
        return {};

    QVariantList result;
    const auto size = model->rowCount();
    for (auto i = 0; i < size; i++) {
        const auto srcIndex = model->index(i, 0);
        if (srcIndex.data(filterRole) == filterValue)
            result.append(srcIndex.data(role));
    }
    return result;
}

/*
 * Finds the index of given value of given value in the model using
 * QAbstractItemModel::match method with Qt::MatchExactly flag.
 *
 * Note: QAbstractItemModel::match Qt::MatchExactly flag performs QVariant-based
 * matching internally. It means that types are not compared and e.g. 4 (int)
 * compared to string "4" will give a positive result.
 */
int ModelUtilsInternal::indexOf(QAbstractItemModel* model,
                                const QString& roleName, const QVariant& value) const
{
    auto role = roleByName(model, roleName);

    if (role == -1 || model->rowCount() == 0)
        return -1;

    QModelIndexList indexes = model->match(model->index(0, 0), role, value, 1,
                                           Qt::MatchExactly);

    if (indexes.isEmpty())
        return -1;

    return indexes.first().row();
}

/*
 * Provides the ability to obtain QPersistentModelIndex on the QML side from
 * regular index fetched from the model via model.index(row, col) method.
 */
QPersistentModelIndex ModelUtilsInternal::persistentIndex(
        QAbstractItemModel* model, int row)
{
    if (!model)
        return {};
    return {model->index(row, 0)};
}

bool ModelUtilsInternal::contains(QAbstractItemModel* model,
                                  const QString& roleName,
                                  const QVariant& value,
                                  int mode) const
{
    if(!model) return false;

    Qt::MatchFlags flags = Qt::MatchFixedString; // Qt::CaseInsensitive by default
    if(mode == Qt::CaseSensitive) flags |= Qt::MatchCaseSensitive;

    auto role = roleByName(model, roleName);

    if (role == -1)
        return false;

    const auto indexes = model->match(model->index(0, 0), role, value, 1, flags);
    return !indexes.isEmpty();
}

bool ModelUtilsInternal::isSameArray(const QJSValue& lhs, const QJSValue& rhs) const
{
    if (!lhs.isArray() || !rhs.isArray())
        return false;

    auto left = lhs.toVariant().toStringList();
    auto right = rhs.toVariant().toStringList();

    if (left.size() != right.size())
        return false;

    left.sort();
    right.sort();

    return left == right;
}
