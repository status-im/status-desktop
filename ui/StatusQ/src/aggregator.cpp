#include "StatusQ/aggregator.h"
#include <QAbstractItemModel>

Aggregator::Aggregator(QObject *parent)
    : QObject(parent){
    connect(this, &Aggregator::modelChanged, this, &Aggregator::recalculate);
}

QAbstractItemModel* Aggregator::model() const {
    return m_model;
}

void Aggregator::setModel(QAbstractItemModel* model) {
    if(m_model == model)
        return;

    if(m_model)
        disconnect(m_model, nullptr, this, nullptr);

    m_model = model;
    connectToModel();
    emit modelChanged();
}

QVariant Aggregator::value() const {
    return m_value;
}

void Aggregator::recalculate()
{
    auto newValue = calculateAggregation();

    if (m_value == newValue)
        return;

    m_value = newValue;
    emit valueChanged();
}

void Aggregator:: connectToModel() {
    if(m_model) {
        connect(m_model, &QAbstractItemModel::rowsInserted, this, &Aggregator::recalculate);
        connect(m_model, &QAbstractItemModel::rowsRemoved, this, &Aggregator::recalculate);
        connect(m_model, &QAbstractItemModel::modelReset, this, &Aggregator::recalculate);
        connect(m_model, &QAbstractItemModel::dataChanged, this,
              [this](auto&, auto&, const QVector<int>& roles) {
          if (this->acceptRoles(roles))
              this->recalculate();
        });
    }
}
