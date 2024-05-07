#pragma once

#include <QJSValue>
#include <QObject>
#include <QVariant>

#include "StatusQ/singleroleaggregator.h"

class FunctionAggregator : public SingleRoleAggregator
{
    Q_OBJECT

    Q_PROPERTY(QVariant initialValue READ initialValue WRITE setInitialValue
               NOTIFY initialValueChanged)

    Q_PROPERTY(QJSValue aggregateFunction READ aggregateFunction
               WRITE setAggregateFunction NOTIFY aggregateFunctionChanged)

public:
    explicit FunctionAggregator(QObject* parent = nullptr);

    const QVariant& initialValue() const;
    void setInitialValue(const QVariant& initialValue);

    const QJSValue& aggregateFunction() const;
    void setAggregateFunction(const QJSValue& aggregateFunction);

signals:
    void initialValueChanged();
    void aggregateFunctionChanged();

protected slots:
     QVariant calculateAggregation() override;

private:
     QVariant m_initialValue;
     QJSValue m_aggregateFunction;
};
