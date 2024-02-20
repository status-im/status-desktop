#pragma once

#include <filters/rolefilter.h>

class UndefinedFilter : public qqsfpm::RoleFilter
{
    Q_OBJECT

public:
    using RoleFilter::RoleFilter;

protected:
    bool filterRow(
            const QModelIndex &sourceIndex,
            const  qqsfpm::QQmlSortFilterProxyModel& proxyModel) const override;
};
