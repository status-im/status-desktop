#pragma once

#include <QObject>
#include <QQmlEngine>

class QAbstractItemModel;

class ModelCount : public QObject {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit ModelCount(QObject* parent = nullptr);

    static ModelCount* qmlAttachedProperties(QObject* object);

    int count() const;

signals:
    void countChanged();

private:
    int m_intermediateCount = 0;
};

QML_DECLARE_TYPEINFO(ModelCount, QML_HAS_ATTACHED_PROPERTIES)
