#pragma once

#include <QObject>
#include <QVariant>

#include "StatusQ/singleroleaggregator.h"

class SumAggregator : public SingleRoleAggregator {

public:
    explicit SumAggregator(QObject *parent = nullptr);

protected slots:
     QVariant calculateAggregation() override;
};
