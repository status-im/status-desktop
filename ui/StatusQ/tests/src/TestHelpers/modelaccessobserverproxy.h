#pragma once

#include <QIdentityProxyModel>

class ModelAccessObserverProxy : public QIdentityProxyModel
{
    Q_OBJECT

public:
    explicit ModelAccessObserverProxy(QObject* parent = nullptr);

    QVariant data(const QModelIndex& index, int role) const override;

signals:
    void dataAccessed(int row, int role, const QVariant& value);
};
