import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

import AppLayouts.Wallet.popups 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.stores 1.0

import Models 1.0

import SortFilterProxyModel 0.2

SplitView {
    id: root

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        ColumnLayout {
            id: controlLayout

            anchors.fill: parent

            // Leave some space so that the popup will be opened without accounting for Layer 
            ColumnLayout {
                Layout.maximumHeight: 50
            }

            NetworkFilter {
                id: networkFilter

                Layout.alignment: Qt.AlignHCenter

                allNetworks: simulatedNimModel
                layer1Networks: SortFilterProxyModel {
                    function rowData(index, propName) {
                        return get(index)[propName]
                    }
                    sourceModel: simulatedNimModel
                    filters: ValueFilter { roleName: "layer"; value: 1; }
                }
                layer2Networks: SortFilterProxyModel {
                    sourceModel: simulatedNimModel
                    filters: [ValueFilter { roleName: "layer"; value: 2; },
                              ValueFilter { roleName: "isTest"; value: false; }]
                }
                enabledNetworks: SortFilterProxyModel {
                    sourceModel: simulatedNimModel
                    filters: ValueFilter { roleName: "isEnabled";  value: true; }
                }

                onToggleNetwork: (network) => {
                    if(multiSelection) {
                        simulatedNimModel.toggleNetwork(network)
                    } else {
                        lastSingleSelectionLabel.text = `[${network.chainName}] (NL) - ID: ${network.chainId}, Icon: ${network.iconUrl}`
                    }
                }

                multiSelection: multiSelectionCheckbox.checked
            }

            // Dummy item to make space for popup
            Item {
                id: popupPlaceholder

                Layout.preferredWidth: networkSelectPopup.width
                Layout.preferredHeight: networkSelectPopup.height

                NetworkSelectPopup {
                    id: networkSelectPopup

                    layer1Networks: networkFilter.layer1Networks
                    layer2Networks: networkFilter.layer2Networks

                    useEnabledRole: false

                    visible: true
                    closePolicy: Popup.NoAutoClose

                    // Simulates a network toggle
                    onToggleNetwork: (network, networkModel, index) => simulatedNimModel.toggleNetwork(network)
                }
            }

            ColumnLayout {
                Layout.preferredHeight: 30
                Layout.maximumHeight: 30
            }

            RowLayout {
                Button {
                    text: "Single Selection Popup"
                    onClicked: selectPopupLoader.active = true
                }
                Label {
                    id: lastSingleSelectionLabel
                    text: "-"
                }
            }

            Item {
                id: singleSelectionPopupPlaceholder

                Layout.preferredWidth: selectPopupLoader.item ? selectPopupLoader.item.width : 0
                Layout.preferredHeight: selectPopupLoader.item ? selectPopupLoader.item.height : 0

                property var currentModel: networkFilter.layer2Networks
                property int currentIndex: 0

                Loader {
                    id: selectPopupLoader

                    active: false

                    sourceComponent: NetworkSelectPopup {
                        layer1Networks: networkFilter.layer1Networks
                        layer2Networks: networkFilter.layer2Networks

                        singleSelection {
                            enabled: true
                            currentModel: singleSelectionPopupPlaceholder.currentModel
                            currentIndex: singleSelectionPopupPlaceholder.currentIndex
                        }

                        onToggleNetwork: (network, networkModel, index) => {
                            lastSingleSelectionLabel.text = `[${network.chainName}] - ID: ${network.chainId}, Icon: ${network.iconUrl}`
                            singleSelectionPopupPlaceholder.currentModel = networkModel
                            singleSelectionPopupPlaceholder.currentIndex = index
                        }

                        onClosed: selectPopupLoader.active = false
                    }

                    onLoaded: item.open()
                }
            }

            // Vertical separator
            ColumnLayout {}
        }
    }
    Pane {
        SplitView.minimumWidth: 300
        SplitView.fillWidth: true
        SplitView.minimumHeight: 300

        ColumnLayout {
            anchors.fill: parent

            ListView {
                id: allNetworksListView

                Layout.fillWidth: true
                Layout.fillHeight: true

                model: simulatedNimModel

                delegate: ItemDelegate {
                    width: allNetworksListView.width
                    implicitHeight: delegateRowLayout.implicitHeight

                    highlighted: ListView.isCurrentItem

                    RowLayout {
                        id: delegateRowLayout
                        anchors.fill: parent

                        Column {
                            Layout.margins: 5

                            spacing: 3

                            Label { text: model.chainName }

                            Row {
                                spacing: 5
                                Label { text: `<b>${model.shortName}</b>` }
                                Label { text: `ID <b>${model.chainId}</b>` }
                                CheckBox {
                                    checkState: model.isEnabled ? Qt.Checked : Qt.Unchecked
                                    tristate: true
                                    nextCheckState: () => {
                                        const nextEnabled = (checkState !== Qt.Checked)
                                        availableNetworks.sourceModel.setProperty(availableNetworks.mapToSource(index), "isEnabled", nextEnabled)
                                        Qt.callLater(() => { simulatedNimModel.cloneModel(availableNetworks) })
                                        return nextEnabled ? Qt.Checked : Qt.Unchecked
                                    }
                                }
                            }
                        }
                    }

                    onClicked: allNetworksListView.currentIndex = index
                }
            }
            CheckBox {
                id: multiSelectionCheckbox

                Layout.margins: 5

                text: "Multi Selection"
                checked: true
            }

            CheckBox {
                id: testModeCheckbox

                Layout.margins: 5

                text: "Test Networks Mode"
                checked: false
                onCheckedChanged: Qt.callLater(simulatedNimModel.cloneModel, availableNetworks)
            }
        }
    }

    SortFilterProxyModel {
        id: availableNetworks

        // Simulate Nim's way of providing access to data
        function rowData(index, propName) {
            return get(index)[propName]
        }

        sourceModel: NetworksModel.allNetworks
        filters: ValueFilter { roleName: "isTest"; value: testModeCheckbox.checked; }
    }

    // Keep a clone so that the UX can be modified without affecting the original model
    CloneModel {
        id: simulatedNimModel

        sourceModel: availableNetworks

        roles: ["chainId", "layer", "chainName", "isTest", "isEnabled", "iconUrl", "shortName", "chainColor"]
        rolesOverride: [{ role: "enabledState", transform: (mD) => {
                return simulatedNimModel.areAllEnabled(sourceModel)
                        ? NetworkSelectItemDelegate.UxEnabledState.AllEnabled
                        : mD.isEnabled
                            ? NetworkSelectItemDelegate.UxEnabledState.Enabled
                            : NetworkSelectItemDelegate.UxEnabledState.Disabled
            }
        }]

        /// Simulate the Nim model
        function toggleNetwork(network) {
            const chainId = network.chainId
            let chainIdOnlyEnabled = true
            let chainIdOnlyDisabled = true
            let allEnabled = true
            for (let i = 0; i < simulatedNimModel.count; i++) {
                const item = simulatedNimModel.get(i)
                if(item.enabledState === NetworkSelectItemDelegate.UxEnabledState.Enabled) {
                    if(item.chainId !== chainId) {
                        chainIdOnlyEnabled = false
                    }
                } else if(item.enabledState === NetworkSelectItemDelegate.UxEnabledState.Disabled) {
                    if(item.chainId !== chainId) {
                        chainIdOnlyDisabled = false
                    }
                    allEnabled = false
                } else {
                    if(item.chainId === chainId) {
                        chainIdOnlyDisabled = false
                        chainIdOnlyEnabled = false
                    }
                }
            }
            for (let i = 0; i < simulatedNimModel.count; i++) {
                const item = simulatedNimModel.get(i)
                if(allEnabled) {
                    simulatedNimModel.setProperty(i, "enabledState", item.chainId === chainId ? NetworkSelectItemDelegate.UxEnabledState.Enabled : NetworkSelectItemDelegate.UxEnabledState.Disabled)
                } else if(chainIdOnlyEnabled || chainIdOnlyDisabled) {
                    simulatedNimModel.setProperty(i, "enabledState", NetworkSelectItemDelegate.UxEnabledState.AllEnabled)
                } else if(item.chainId === chainId) {
                    simulatedNimModel.setProperty(i, "enabledState", item.enabledState === NetworkSelectItemDelegate.UxEnabledState.Enabled
                        ? NetworkSelectItemDelegate.UxEnabledState.Disabled
                        :NetworkSelectItemDelegate.UxEnabledState.Enabled)
                }
                const haveEnabled = item.enabledState !== NetworkSelectItemDelegate.UxEnabledState.Disabled
                if(item.isEnabled !== haveEnabled) {
                    simulatedNimModel.setProperty(i, "isEnabled", haveEnabled)
                }
            }
        }

        function areAllEnabled(modelToCheck) {
            for (let i = 0; i < modelToCheck.count; i++) {
                if(!(modelToCheck.get(i).isEnabled)) {
                    return false
                }
            }
            return true
        }
    }
}

// category: Popups

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=13200-352357&t=jKciSCy3BVlrZmBs-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=13185-350333&t=b2AclcJgxjXDL6Wl-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=13187-359097&t=b2AclcJgxjXDL6Wl-0
