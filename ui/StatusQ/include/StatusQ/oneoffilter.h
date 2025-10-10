#pragma once

#include <filters/rolefilter.h>

#include <QVariant>

class OneOfFilter : public qqsfpm::RoleFilter
{
    Q_OBJECT

    Q_PROPERTY(QVariant array READ array WRITE setArray NOTIFY paramsChanged FINAL REQUIRED)
    Q_PROPERTY(QString separator READ separator WRITE setSeparator NOTIFY paramsChanged FINAL)

    Q_PROPERTY(QStringList actualArray READ actualArray NOTIFY actualArrayChanged FINAL)

public:
    explicit OneOfFilter(QObject *parent = nullptr);

protected:
    bool filterRow(const QModelIndex& sourceIndex, const qqsfpm::QQmlSortFilterProxyModel& proxyModel) const override;
    void proxyModelCompleted(const qqsfpm::QQmlSortFilterProxyModel& proxyModel) override;

signals:
    void paramsChanged();
    void actualArrayChanged();

private:
    QVariant m_array;
    QVariant array() const;
    void setArray(const QVariant &newArray);

    QString m_separator;
    QString separator() const;
    void setSeparator(const QString &newSeparator);

    QStringList m_actualArray;
    QStringList actualArray() const;
    void updateActualArray();
};
