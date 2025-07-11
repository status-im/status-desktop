import SortFilterProxyModel

import StatusQ.Core.Utils

SortFilterProxyModel {
    id: root

    property string searchText
    readonly property string searchTextLowerCase: searchText.toLowerCase()

    property int sortBy: TokenHoldersProxyModel.SortBy.Username
    property int sortOrder: Qt.AscendingOrder

    enum SortBy {
        None, Username, NumberOfMessages, Holding
    }

    filters: AnyOf {
        SearchFilter {
            roleName: "name"
            searchPhrase: searchText
        }
        SearchFilter {
            roleName: "displayName"
            searchPhrase: searchText
        }
        SearchFilter {
            roleName: "ensName"
            searchPhrase: searchText
        }
        SearchFilter {
            roleName: "localNickname"
            searchPhrase: searchText
        }
        SearchFilter {
            roleName: "walletAddress"
            searchPhrase: searchText
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

            priority: 5
        },

        RoleSorter {
            enabled: root.sortBy === TokenHoldersProxyModel.SortBy.Username
            roleName: "localNickname"
            sortOrder: root.sortOrder
            priority: 1
        },

        RoleSorter {
            enabled: root.sortBy === TokenHoldersProxyModel.SortBy.Username
            roleName: "name"
            sortOrder: root.sortOrder
            priority: 1
        },

        RoleSorter {
            enabled: root.sortBy === TokenHoldersProxyModel.SortBy.Username
            roleName: "ensName"
            sortOrder: root.sortOrder
            priority: 2
        },

        RoleSorter {
            enabled: root.sortBy === TokenHoldersProxyModel.SortBy.Username
            roleName: "displayName"
            sortOrder: root.sortOrder
            priority: 3
        },

        RoleSorter {
            enabled: root.sortBy === TokenHoldersProxyModel.SortBy.Username
            roleName: "alias"
            sortOrder: root.sortOrder
            priority: 4
        },

        RoleSorter {
            enabled: root.sortBy === TokenHoldersProxyModel.SortBy.Username
            roleName: "walletAddress"
            sortOrder: root.sortOrder
            priority: 5
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
