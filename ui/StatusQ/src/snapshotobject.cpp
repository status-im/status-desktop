#include "StatusQ/snapshotobject.h"

#include "StatusQ/snapshotmodel.h"

#include <QDebug>
#include <QMetaProperty>

SnapshotObject::SnapshotObject(QObject* parent)
    : QObject(parent)
{ }

SnapshotObject::SnapshotObject(const QObject* object, QObject* parent)
    : QObject(parent)
{
    grabSnapshot(object);
}

QVariant SnapshotObject::snapshot() const
{
    return m_snapshot;
}

bool SnapshotObject::available() const
{
    return m_available;
}

void SnapshotObject::setAvailable(bool available)
{
    if(m_available == available) return;

    m_available = available;
    emit availableChanged();
}

void SnapshotObject::setSnapshot(const QVariant& snapshot)
{
    if(m_snapshot == snapshot) return;

    m_snapshot = snapshot;

    // available emit order is important
    if (!m_snapshot.isValid()) setAvailable(false);

    emit snapshotChanged();

    if (m_snapshot.isValid()) setAvailable(true);
}

void SnapshotObject::grabSnapshot(const QObject* object)
{
    if(!object)
    {
        setSnapshot({});
        return;
    }

    // try cast to QAbstractItemModel
    if(const auto model = qobject_cast<const QAbstractItemModel*>(object))
    {
        setSnapshot(modelToVariant(model));
        return;
    }

    setSnapshot(QVariant::fromValue(objectToVariantMap(object)));
}

QVariantMap SnapshotObject::objectToVariantMap(const QObject* object)
{
    if(!object)
    {
        return {};
    }

    QVariantMap item;

    const auto metaObject = object->metaObject();
    const auto count = metaObject->propertyCount();
    const auto propertyOffset = metaObject->propertyOffset();

    for(int i = propertyOffset; i < propertyOffset + count; i++)
    {
        const auto property = metaObject->property(i);
        const auto name = property.name();
        const auto value = property.read(object);

        insertIntoVariantMap(item, name, value);
    }

    const auto dynamicPropertyNames = object->dynamicPropertyNames();
    for(const auto& name : dynamicPropertyNames)
    {
        const auto value = object->property(name);
        insertIntoVariantMap(item, name, value);
    }

    return item;
}

QVariant SnapshotObject::objectToVariant(const QObject* object)
{
    if(auto model = qobject_cast<const QAbstractItemModel*>(object))
    {
        return modelToVariant(model);
    }

    return {objectToVariantMap(object)};
}

QVariant SnapshotObject::modelToVariant(const QAbstractItemModel* model)
{
    if(!model)
    {
        return {};
    }

    auto modelSnapshot = new SnapshotModel(*model, true, this);
    connect(this, &SnapshotObject::snapshotChanged, modelSnapshot, [modelSnapshot]() { modelSnapshot->deleteLater(); });
    return QVariant::fromValue(modelSnapshot);
}


void SnapshotObject::insertIntoVariantMap(QVariantMap& map, const QString& key, const QVariant& value)
{
    if(value.canConvert<QObject*>())
    {
        map.insert(key, objectToVariant(value.value<QObject*>()));
        return;
    }

    map.insert(key, value);
}
