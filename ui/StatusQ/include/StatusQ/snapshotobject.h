#pragma once

#include <QObject>
#include <QVariantMap>

class QAbstractItemModel;
class SnapshotObject : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariant snapshot READ snapshot NOTIFY snapshotChanged)
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)

public:
    explicit SnapshotObject(QObject* parent = nullptr);
    explicit SnapshotObject(const QObject* object, QObject* parent);

    QVariant snapshot() const;
    bool available() const;

    Q_INVOKABLE void grabSnapshot(const QObject* object);

signals:
    void snapshotChanged();
    void availableChanged();

private:
    void setAvailable(bool available);
    void setSnapshot(const QVariant& snapshot);

    QVariantMap objectToVariantMap(const QObject* object);
    QVariant objectToVariant(const QObject* object);
    QVariant modelToVariant(const QAbstractItemModel* model);
    void insertIntoVariantMap(QVariantMap& map, const QString& key, const QVariant& value);

    QVariant m_snapshot;
    bool m_available{false};
};