import QtQuick 2.15

import Models 1.0

import SortFilterProxyModel 0.2

QtObject {
    id: root
    property bool areTestNetworksEnabled: false
    property SortFilterProxyModel allNetworks: SortFilterProxyModel {
        sourceModel: NetworksModel.flatNetworks
        sorters: [
            RoleSorter {
                roleName: "layer"
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
