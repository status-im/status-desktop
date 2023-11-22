#pragma once

#include <QJSValue>
#include <QObject>
#include <QString>
#include <QVariant>

class QAbstractItemModel;
class QJSEngine;
class QQmlEngine;

class ModelUtilsInternal : public QObject
{
    Q_OBJECT

public:
    explicit ModelUtilsInternal(QObject* parent = nullptr);

    Q_INVOKABLE bool isModel(const QVariant &obj) const;

    Q_INVOKABLE int roleByName(QAbstractItemModel *model,
                               const QString &roleName) const;

    Q_INVOKABLE QStringList roleNames(QAbstractItemModel *model) const;

    Q_INVOKABLE QVariantMap get(QAbstractItemModel *model, int row) const;
    Q_INVOKABLE QVariant get(QAbstractItemModel *model, int row,
                             const QString &roleName) const;

    Q_INVOKABLE QVariantList getAll(QAbstractItemModel* model,
                                    const QString& roleName,
                                    const QString& filterRoleName,
                                    const QVariant& filterValue) const;

    Q_INVOKABLE bool contains(QAbstractItemModel *model, const QString &roleName, const QVariant &value, int mode = Qt::CaseSensitive) const;

    ///< performs a strict check whether @lhs and @rhs arrays (QList<T>) contain the same elements;
    /// eg. `["a", "c", "b"]` and `["b", "c", "a"]` are considered equal
    Q_INVOKABLE bool isSameArray(const QJSValue& lhs, const QJSValue& rhs) const;

    static QObject* qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
    {
        Q_UNUSED(engine);
        Q_UNUSED(scriptEngine);

        return new ModelUtilsInternal;
    }
};
