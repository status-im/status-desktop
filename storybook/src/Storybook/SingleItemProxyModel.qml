import SortFilterProxyModel

SortFilterProxyModel {
    property alias roleName: valueFilter.roleName
    property alias value: valueFilter.value

    filters: ValueFilter {
        id: valueFilter
    }
}
