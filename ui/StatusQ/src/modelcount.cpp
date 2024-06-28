#include "StatusQ/modelcount.h"

#include <QAbstractItemModel>

ModelCount::ModelCount(QObject* parent) : QObject(parent)
{
    auto model = qobject_cast<QAbstractItemModel*>(parent);

    if (model == nullptr)
        return;

    connect(model, &QAbstractItemModel::rowsInserted,
            this, &ModelCount::countChanged);
    connect(model, &QAbstractItemModel::rowsRemoved,
            this, &ModelCount::countChanged);

    auto storeIntermediateCount = [this, model] {
        this->m_intermediateCount = model->rowCount();
    };

    auto emitIfChanged = [this, model] {
        if (this->m_intermediateCount != model->rowCount())
            emit this->countChanged();
    };

    connect(model, &QAbstractItemModel::modelAboutToBeReset, this, storeIntermediateCount);
    connect(model, &QAbstractItemModel::layoutAboutToBeChanged, storeIntermediateCount);

    connect(model, &QAbstractItemModel::modelReset, this, emitIfChanged);
    connect(model, &QAbstractItemModel::layoutChanged, this, emitIfChanged);
}

ModelCount* ModelCount::qmlAttachedProperties(QObject* object)
{
    return new ModelCount(object);
}

int ModelCount::count() const
{
    if (auto model = qobject_cast<QAbstractItemModel*>(parent()))
        return model->rowCount();

    return 0;
}
