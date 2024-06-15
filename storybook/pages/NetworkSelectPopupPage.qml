import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
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

            // Leave some space so that the popup will be opened without accounting for Layer 
            ColumnLayout {
                Layout.maximumHeight: 50
            }

            NetworkFilter {
                id: networkFilter

                Layout.alignment: Qt.AlignHCenter

                flatNetworks: availableNetworks
                multiSelection: multiSelectionCheckbox.checked
            }

            // Dummy item to make space for popup
            Item {
                id: popupPlaceholder

                Layout.preferredWidth: networkSelectPopup.implicitWidth
                Layout.preferredHeight: networkSelectPopup.implicitHeight

                NetworkSelectPopup {
                    id: networkSelectPopup
                    flatNetworks: availableNetworks
                    multiSelection: multiSelectionCheckbox.checked
                    closePolicy: Popup.NoAutoClose
                    visible: true
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
                    text: selectedEntry.available ? `[${selectedEntry.item.chainName}] - ID: ${selectedEntry.item.chainId}, Icon: ${selectedEntry.item.iconUrl}` : "-"
                }

                ModelEntry {
                    id: selectedEntry
                    sourceModel: availableNetworks
                    key: "chainId"
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
                        flatNetworks: availableNetworks
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
        SplitView.minimumWidth: 300
        SplitView.fillWidth: true
        SplitView.minimumHeight: 300

        ColumnLayout {
            anchors.fill: parent

            ListView {
                id: allNetworksListView

                Layout.fillWidth: true
                Layout.fillHeight: true

                model: availableNetworks

                delegate: ItemDelegate {
                    required property var model

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
                                    checkState: networkSelectPopup.selection.includes(model.chainId) ? Qt.Checked : Qt.Unchecked
                                    onToggled: {
                                        let currentSelection = networkSelectPopup.selection
                                        if (checkState === Qt.Checked && !currentSelection.includes(model.chainId)) {
                                            currentSelection.push(model.chainId)
                                        } else {
                                            currentSelection = currentSelection.filter(id => id !== model.chainId)
                                        }
                                        networkSelectPopup.selection = [...currentSelection]
                                    }
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

    SortFilterProxyModel {
        id: availableNetworks

        sourceModel: NetworksModel.flatNetworks
        filters: ValueFilter { roleName: "isTest"; value: testModeCheckbox.checked; }
    }
}

// category: Popups

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=13200-352357&t=jKciSCy3BVlrZmBs-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=13185-350333&t=b2AclcJgxjXDL6Wl-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=13187-359097&t=b2AclcJgxjXDL6Wl-0
