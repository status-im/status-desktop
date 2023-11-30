#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <QVariant>

class QAbstractItemModel;

class Aggregator : public QObject {
    Q_OBJECT

    Q_PROPERTY(QAbstractItemModel* model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QVariant value READ value NOTIFY valueChanged)

public:
    explicit Aggregator(QObject *parent = nullptr);

    QAbstractItemModel* model() const;
    void setModel(QAbstractItemModel* model);

    QVariant value() const;

signals:
    void modelChanged();    
    void valueChanged();

protected slots:
    virtual QVariant calculateAggregation() = 0;

protected:
    void recalculate();
    virtual bool acceptRoles(const QVector<int>& roles) { return true; };

private:
    QAbstractItemModel* m_model = nullptr;
    QVariant m_value;

    void connectToModel();
};
