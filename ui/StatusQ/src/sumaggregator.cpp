#include "StatusQ/sumaggregator.h"

#include <QDebug>

SumAggregator::SumAggregator(QObject *parent)
    : SingleRoleAggregator(parent) {
    recalculate();
}

QVariant SumAggregator::calculateAggregation() {
    // Check if m_model exists and role name is initialized
    if (!model() || roleName().isEmpty())
        return 0.0;

    // Check if m_roleName is part of the roles of the model
    QHash<int, QByteArray> roles = model()->roleNames();
    if (!roleExists()) {
        qWarning() << "Provided role name does not exist in the current model";
        return 0.0;
    }

    // Do the aggregation
    double total = 0.0;
    int rows = model()->rowCount();
    int role = roles.key(roleName());

    for (int row = 0; row < rows; ++row) {
        QModelIndex index = model()->index(row, 0);
        QVariant value = model()->data(index, role);

        bool ok;
        total += value.toDouble(&ok);

        if (!ok)
          qWarning() << "Unsupported type for given role (not convertible to double)";
    }

    return total;
}
