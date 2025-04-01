import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Popups 0.1

import utils 1.0

import AppLayouts.Wallet.popups 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.views 1.0
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

            RowLayout {
                Layout.fillWidth: true

                // Dummy item to make space for popup
                Item {
                    id: popupPlaceholder

                    Layout.preferredWidth: networkSelectPopup.implicitWidth
                    Layout.preferredHeight: networkSelectPopup.implicitHeight
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop

                    NetworkSelectPopup {
                        id: networkSelectPopup
                        flatNetworks: d.activeNetworks
                        multiSelection: multiSelectionCheckbox.checked
                        showManageNetworksButton: showManageNetworksButtonCheckbox.checked
                        closePolicy: Popup.NoAutoClose
                        visible: true
                        Binding on selection {
                            value: d.selection
                        }
                        onToggleNetwork: d.toggleNetworkEnabled(chainId)
                    }
                }

                // Filler
                ColumnLayout {
                    Layout.preferredHeight: 100
                    Layout.maximumHeight: 100
                }

                Item {
                    id: filterPlaceholder

                    Layout.preferredWidth: networkFilter.implicitWidth
                    Layout.preferredHeight: networkFilter.implicitHeight
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    
                    NetworkFilter {
                        id: networkFilter

                        flatNetworks: d.activeNetworks
                        multiSelection: multiSelectionCheckbox.checked
                        showManageNetworksButton: showManageNetworksButtonCheckbox.checked
                        Binding on selection {
                            value: d.selection
                        }
                        onToggleNetwork: d.toggleNetworkEnabled(chainId)
                    }
                }
            }

            ColumnLayout {
                Layout.preferredHeight: 100
                Layout.maximumHeight: 100
            }

            RowLayout {
                Button {
                    text: "Single Selection Popup"
                    onClicked: selectPopupLoader.active = true
                }
                Label {
                    id: lastSingleSelectionLabel
                    text: selectedEntry.available ? `[${selectedEntry.item.chainName}] - ID: ${selectedEntry.item.chainId}, Icon: ${selectedEntry.item.iconUrl}` : "-"
                }

                ModelEntry {
                    id: selectedEntry
                    sourceModel: d.activeNetworks
                    key: "chainId"
                    value: ""
                }
            }

            Item {
                id: singleSelectionPopupPlaceholder

                Layout.preferredWidth: selectPopupLoader.item ? selectPopupLoader.item.implicitWidth : 0
                Layout.preferredHeight: selectPopupLoader.item ? selectPopupLoader.item.implicitHeight : 0

                property var currentModel: networkFilter.flatNetworks
                property int currentIndex: 0

                Loader {
                    id: selectPopupLoader

                    active: false

                    sourceComponent: NetworkSelectPopup {
                        flatNetworks: d.activeNetworks
                        selection: selectedEntry.available ? [selectedEntry.value] : []
                        onClosed: selectPopupLoader.active = false

                        onSelectionChanged: {
                            if (selectedEntry.value !== selection[0]) {
                                selectedEntry.value = selection[0]
                            }
                        }
                    }

                    onLoaded: item.open()
                }
            }

            // Vertical separator
            ColumnLayout {}
        }
    }
    Pane {
        SplitView.minimumWidth: 400
        SplitView.fillWidth: true
        SplitView.minimumHeight: 300

        ColumnLayout {
            anchors.fill: parent

            ListView {
                id: allNetworksListView

                Layout.fillWidth: true
                Layout.fillHeight: true

                model: d.availableNetworks

                delegate: ItemDelegate {
                    required property var model

                    width: allNetworksListView.width
                    implicitHeight: delegateRowLayout.implicitHeight

                    highlighted: ListView.isCurrentItem

                    RowLayout {
                        id: delegateRowLayout
                        anchors.fill: parent

                        ColumnLayout {
                            Layout.margins: 5

                            spacing: 3

                            Label { text: model.chainName }

                            RowLayout {
                                spacing: 5
                                Label { text: `<b>${model.shortName}</b>` }
                                Label { text: `ID <b>${model.chainId}</b>` }
                                CheckBox {
                                    text: "Enabled"
                                    checkState: model.isEnabled ? Qt.Checked : Qt.Unchecked
                                    onToggled: d.setIsEnabled(model.chainId, checkState === Qt.Checked)
                                }
                                CheckBox {
                                    text: "Active"
                                    checkState: model.isActive ? Qt.Checked : Qt.Unchecked
                                    onToggled: d.setIsActive(model.chainId, checkState === Qt.Checked)
                                }
                            }
                        }
                    }
                }
            }
            CheckBox {
                id: multiSelectionCheckbox

                Layout.margins: 5

                text: "Multi Selection"
                checked: true
            }

            CheckBox {
                id: showManageNetworksButtonCheckbox

                Layout.margins: 5

                text: "Show 'Manage networks' button"
                checked: true
            }


            CheckBox {
                id: testModeCheckbox

                Layout.margins: 5

                text: "Test Networks Mode"
                checked: false
            }

            CheckBox {
                id: allowSelection
                Layout.margins: 5

                text: "Allow Selection"
                checked: networkSelectPopup.selectionAllowed
                onToggled: networkSelectPopup.selectionAllowed = checked
            }
        }
    }

    QtObject {
        id: d

        function toggleNetworkEnabled(chainId) {
            let isEnabled = ModelUtils.getByKey(NetworksModel.flatNetworks, "chainId", chainId, "isEnabled")
            d.setIsEnabled(chainId, !isEnabled)
        }
        function setIsEnabled(chainId, value) {
            let index = ModelUtils.indexOf(NetworksModel.flatNetworks, "chainId", chainId)
            NetworksModel.flatNetworks.setProperty(index, "isEnabled", value)
        }
        function setIsActive(chainId, value) {
            let index = ModelUtils.indexOf(NetworksModel.flatNetworks, "chainId", chainId)
            NetworksModel.flatNetworks.setProperty(index, "isActive", value)
        }

        readonly property var availableNetworks: SortFilterProxyModel {
            sourceModel: NetworksModel.flatNetworks
            filters: [
                ValueFilter { roleName: "isTest"; value: testModeCheckbox.checked; }
            ]
        }

        readonly property var activeNetworks: SortFilterProxyModel {
            sourceModel: d.availableNetworks
            filters: [
                ValueFilter { roleName: "isActive"; value: true; }
            ]
        }

        readonly property var enabledNetworks: SortFilterProxyModel {
            sourceModel: d.activeNetworks
            filters: [
                ValueFilter { roleName: "isEnabled"; value: true; }
            ]
        }

        readonly property var chainIdsAggregator: FunctionAggregator {
            model: d.enabledNetworks
            initialValue: []
            roleName: "chainId"

            aggregateFunction: (aggr, value) => [...aggr, value]
        }

        readonly property var selection: d.chainIdsAggregator.value
    }


}

// category: Popups

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=13200-352357&t=jKciSCy3BVlrZmBs-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=13185-350333&t=b2AclcJgxjXDL6Wl-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=13187-359097&t=b2AclcJgxjXDL6Wl-0
