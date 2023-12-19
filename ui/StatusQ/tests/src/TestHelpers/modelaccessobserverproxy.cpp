#include "modelaccessobserverproxy.h"


ModelAccessObserverProxy::ModelAccessObserverProxy(QObject* parent)
    : QIdentityProxyModel{parent}
{
}

QVariant ModelAccessObserverProxy::data(const QModelIndex& index, int role) const
{
    QVariant result;

    if (checkIndex(index))
        result = QIdentityProxyModel::data(index, role);

    emit const_cast<ModelAccessObserverProxy*>(this)->dataAccessed(
                index.row(), role, result);

    return result;
}
