import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1

import Models 1.0

import AppLayouts.Wallet.views 1.0

SplitView {
    id: root

    Pane {
        id: mainPane
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        ColumnLayout {
            anchors.fill: parent
            Label {
                text: "Radio Buttons"
                font.bold: true
            }

            NetworkSelectorView {
                id: networkSelectorView
                
                Layout.fillWidth: true
                Layout.fillHeight: true
            
                model: NetworksModel.flatNetworks
                selection: [11155420]
                showIndicator: true
                multiSelection: false
                showNewChainIcon: ctrlNewChainIcon.checked
            }

            Label {
                text: "Checkboxes"
                font.bold: true
            }

            NetworkSelectorView {
                id: networkSelectorView2
                
                Layout.fillWidth: true
                Layout.fillHeight: true
            
                model: NetworksModel.flatNetworks
                showIndicator: true
                multiSelection: true
                showNewChainIcon: ctrlNewChainIcon.checked

                selection: [1, 11155420]
            }
        }
    }

    Pane {
        id: controls
        SplitView.preferredWidth: 300
        SplitView.fillHeight: true
        Column {
            anchors.fill: parent
            Label {
                text: "Simulate backend state"
                font.bold: true
            }

            Label {
                text: "Radio buttons control"
            }
            Repeater {
                model: NetworksModel.flatNetworks
                delegate: CheckBox {
                    text: model.chainName
                    checked: networkSelectorView.selection.includes(model.chainId)
                    onToggled: {
                        if (checked) {
                            networkSelectorView.selection = [model.chainId]
                        }
                    }
                }
            }

            Label {
                text: "Checkboxes control"
            }

            Repeater {
                model: NetworksModel.flatNetworks
                delegate: CheckBox {
                    text: model.chainName
                    checked: networkSelectorView2.selection.includes(model.chainId)
                    onToggled: {
                        if (checked) {
                            const selection = networkSelectorView2.selection
                            selection.push(model.chainId)
                            networkSelectorView2.selection = selection
                        } else {
                            networkSelectorView2.selection = networkSelectorView2.selection.filter((id) => id !== model.chainId)
                        }
                    }
                }
            }

            CheckBox {
                id: ctrlNewChainIcon
                text: "Show new chain icon"
                checked: true
                topPadding: 24
            }
        }
    }
}

// category: Views
// status: good
