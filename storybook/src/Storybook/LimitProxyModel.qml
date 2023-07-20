import SortFilterProxyModel 0.2

SortFilterProxyModel {
    id: root

    property int limit

    filters: IndexFilter {
        maximumIndex: Math.max(root.limit - 1, 0)
        minimumIndex: root.limit === 0 ? 1 : 0
    }
}
