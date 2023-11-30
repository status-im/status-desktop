#pragma once

#include <QObject>

#include "StatusQ/aggregator.h"

class SingleRoleAggregator : public Aggregator {
    Q_OBJECT

    Q_PROPERTY(QByteArray roleName READ roleName WRITE setRoleName NOTIFY roleNameChanged)

public:
    explicit SingleRoleAggregator(QObject *parent = nullptr);

    const QByteArray& roleName() const;
    void setRoleName(const QByteArray &roleName);

signals:
    void roleNameChanged();

protected:
    bool acceptRoles(const QVector<int>& roles) override;
    bool roleExists() const;

private:
    QByteArray m_roleName;
};
