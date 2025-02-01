import QtQml 2.15
import QtQuick 2.15

import shared.status 1.0
import shared.popups 1.0
import shared.panels 1.0


import AppLayouts.Profile.popups.networkSettings 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0

import SortFilterProxyModel 0.2

import "../../stores"
import "../../controls"

Item {
    id: root
    signal goBack

    readonly property int mainnetTabIndex: 0
    readonly property int testnetTabIndex: 1

    required property var flatNetworks
    required property bool areTestNetworksEnabled

    signal editNetwork(int chainId)
    signal setNetworkActive(int chainId, bool active)

    function overrideInitialTabIndex(index) {
        d.overrideInitialTabIndex = index
    }

    onAreTestNetworksEnabledChanged: d.checkTestModeTab()

    QtObject {
        id: d

        Component.onCompleted: d.checkTestModeTab()

        property int overrideInitialTabIndex: -1

        function checkTestModeTab() {
            if (d.overrideInitialTabIndex >= 0) {
                testModeViewTabBar.currentIndex = d.overrideInitialTabIndex
                d.overrideInitialTabIndex = -1
                return
            }
            testModeViewTabBar.currentIndex = root.areTestNetworksEnabled ? root.testnetTabIndex : root.mainnetTabIndex
        }

        property var currentTestModeNetworks: SortFilterProxyModel {
            sourceModel: root.flatNetworks
            filters: ValueFilter {
                roleName: "isTest"
                value: testModeViewTabBar.currentIndex == root.testnetTabIndex
            }
            sorters: [
                RoleSorter {
                    roleName: "isActive"
                    sortOrder: Qt.DescendingOrder
                },
                RoleSorter {
                    roleName: "layer"
                    sortOrder: Qt.AscendingOrder
                },
                RoleSorter {
                    roleName: "chainName"
                    sortOrder: Qt.AscendingOrder
                }
            ]
        }

        property var currentActiveNetworks: SortFilterProxyModel {
            sourceModel: d.currentTestModeNetworks
            filters: ValueFilter {
                roleName: "isActive"
                value: true
            }
        }

        readonly property int currentActiveNetworksCount: d.currentActiveNetworks.ModelCount.count
    }

    Column {
        id: column
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        spacing: 0

        StatusTabBar {
            id: testModeViewTabBar
            objectName: "testModeViewTabBar"
            StatusTabButton {
                text: qsTr("Mainnet")
                objectName: "testModeViewMainButton"
                width: implicitWidth
            }
            StatusTabButton {
                text: qsTr("Testnet")
                objectName: "testModeViewTestButton"
                width: implicitWidth
            }
        }

        Repeater {
            id: networkList
            model: SortFilterProxyModel {
                sourceModel: root.flatNetworks
                filters: ValueFilter {
                    roleName: "isTest"
                    value: testModeViewTabBar.currentIndex == root.testnetTabIndex
                }
                sorters: [
                    RoleSorter {
                        roleName: "isActive"
                        sortOrder: Qt.DescendingOrder
                    },
                    RoleSorter {
                        roleName: "layer"
                        sortOrder: Qt.AscendingOrder
                    },
                    RoleSorter {
                        roleName: "chainName"
                        sortOrder: Qt.AscendingOrder
                    }
                ]
            }
            delegate: WalletNetworkDelegate {
                objectName: "walletNetworkDelegate_" + model.chainName + '_' + model.chainId
                chainName: model.chainName
                iconUrl: model.iconUrl
                isActive: model.isActive
                isDeactivatable: model.isDeactivatable
                
                onSetNetworkActive: {
                    if (!active) {
                        // Launch confirmation popup
                        Global.openPopup(deactivateNetworkPopupComponent, {chainId: model.chainId, iconUrl: model.iconUrl, chainName: model.chainName})
                        return
                    }
                    if (d.currentActiveNetworksCount >= Constants.maxActiveNetworks && active) {
                        Global.openPopup(activeNetworkLimitPopupComponent)
                        return
                    }
                    // Set network active
                    root.setNetworkActive(model.chainId, active)
                }

                onEditNetwork: root.editNetwork(model.chainId)
            }
        }
    }

    Component {
        id: deactivateNetworkPopupComponent
        DeactivateNetworkPopup {
            width: 556
            onAccepted: {
                root.setNetworkActive(chainId, false)
            }
        }
    }

    Component {
        id: activeNetworkLimitPopupComponent
        ActiveNetworkLimitPopup {
            width: 521
        }
    }
}
