#include "StatusQ/undefinedfilter.h"

#include <qqmlsortfilterproxymodel.h>

using namespace qqsfpm;

bool UndefinedFilter::filterRow(const QModelIndex& sourceIndex,
                                const QQmlSortFilterProxyModel& proxyModel) const
{
    return !sourceData(sourceIndex, proxyModel).isValid();
}
