#pragma once

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

    Q_INVOKABLE int roleByName(QAbstractItemModel *model,
                               const QString &roleName) const;

    Q_INVOKABLE QStringList roleNames(QAbstractItemModel *model) const;

    Q_INVOKABLE QVariantMap get(QAbstractItemModel *model, int row) const;
    Q_INVOKABLE QVariant get(QAbstractItemModel *model, int row,
                             const QString &roleName) const;

    Q_INVOKABLE bool contains(QAbstractItemModel *model, const QString &roleName, const QVariant &value, int mode = Qt::CaseSensitive) const;

    static QObject* qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
    {
        Q_UNUSED(engine);
        Q_UNUSED(scriptEngine);

        return new ModelUtilsInternal;
    }
};
