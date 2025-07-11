import QtQuick

import Models

import SortFilterProxyModel

QtObject {
    id: root
    property bool areTestNetworksEnabled: false
    property SortFilterProxyModel allNetworks: SortFilterProxyModel {
        sourceModel: NetworksModel.flatNetworks
        sorters: [
            RoleSorter {
                roleName: "isDeactivatable"
                sortOrder: Qt.AscendingOrder
            },
            RoleSorter {
                roleName: "isActive"
                sortOrder: Qt.DescendingOrder
            },
            RoleSorter {
                roleName: "chainName"
                sortOrder: Qt.AscendingOrder
            }
        ]
    }
    property SortFilterProxyModel activeNetworks: SortFilterProxyModel {
        sourceModel: root.allNetworks
        filters: [
            ValueFilter { roleName: "isTest"; value: root.areTestNetworksEnabled },
            ValueFilter { roleName: "isActive"; value: true }
        ]
    }
}
