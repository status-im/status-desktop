import SortFilterProxyModel 0.2

SortFilterProxyModel {
    id: root

    property string searchText
    readonly property string searchTextLowerCase: searchText.toLowerCase()

    property int sortBy: TokenHoldersProxyModel.SortBy.Username
    property int sortOrder: Qt.AscendingOrder

    enum SortBy {
        None, Username, NumberOfMessages, Holding
    }

    filters: ExpressionFilter {
        expression: {
            root.searchTextLowerCase

            const nameLowerCase = model.name.toLowerCase()
            const addressLowerCase = model.walletAddress.toLowerCase()

            return nameLowerCase.includes(searchTextLowerCase) ||
                    addressLowerCase.includes(searchTextLowerCase)
        }
    }

    sorters: [
        FilterSorter {
            enabled: root.sortBy === TokenHoldersProxyModel.SortBy.Username

            ValueFilter {
                roleName: "name"
                value: ""
                inverted: true
            }

            priority: 3
        },

        RoleSorter {
            enabled: root.sortBy === TokenHoldersProxyModel.SortBy.Username
            roleName: "name"
            sortOrder: root.sortOrder
            priority: 2
        },

        RoleSorter {
            enabled: root.sortBy === TokenHoldersProxyModel.SortBy.Username
            roleName: "walletAddress"
            sortOrder: root.sortOrder
            priority: 1
        },

        RoleSorter {
            enabled: root.sortBy === TokenHoldersProxyModel.SortBy.NumberOfMessages
            roleName: "numberOfMessages"
            sortOrder: root.sortOrder
        },

        RoleSorter {
            enabled: root.sortBy === TokenHoldersProxyModel.SortBy.Holding
            roleName: "amount"
            sortOrder: root.sortOrder
        }
    ]
}
