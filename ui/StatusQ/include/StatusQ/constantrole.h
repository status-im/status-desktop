#pragma once

#include <proxyroles/singlerole.h>
#include <QVariant>

class ConstantRole : public qqsfpm::SingleRole
{
    Q_OBJECT
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)

public:
    using SingleRole::SingleRole;

    const QVariant& value() const;
    void setValue(const QVariant& value);

Q_SIGNALS:
    void valueChanged();

private:
    QVariant data(const QModelIndex& sourceIndex,
                  const qqsfpm::QQmlSortFilterProxyModel& proxyModel) override;

    QVariant m_value;

};
