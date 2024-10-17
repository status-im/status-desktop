#include "StatusQ/modelcount.h"

#include <QAbstractItemModel>

ModelCount::ModelCount(QObject* parent) : QObject(parent)
{
    auto model = qobject_cast<QAbstractItemModel*>(parent);

    if (model == nullptr)
        return;

    m_count = model->rowCount();

    auto update = [this, model] {
        auto wasEmpty = m_count == 0;
        auto count = model->rowCount();

        if (m_count == count)
            return;

        m_count = count;
        emit this->countChanged();

        if (wasEmpty != (count == 0))
            this->emptyChanged();
    };

    connect(model, &QAbstractItemModel::rowsInserted, this, update);
    connect(model, &QAbstractItemModel::rowsRemoved, this, update);
    connect(model, &QAbstractItemModel::modelReset, this, update);
    connect(model, &QAbstractItemModel::layoutChanged, this, update);
}

ModelCount* ModelCount::qmlAttachedProperties(QObject* object)
{
    return new ModelCount(object);
}

int ModelCount::count() const
{
    return m_count;
}

bool ModelCount::empty() const
{
    return m_count == 0;
}
