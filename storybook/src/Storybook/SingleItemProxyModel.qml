import SortFilterProxyModel 0.2

SortFilterProxyModel {
    property alias roleName: valueFilter.roleName
    property alias value: valueFilter.value

    filters: ValueFilter {
        id: valueFilter
    }
}
