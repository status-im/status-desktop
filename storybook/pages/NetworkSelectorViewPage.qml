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
                id: networkSelectionView
                
                Layout.fillWidth: true
                Layout.fillHeight: true
            
                model: NetworksModel.flatNetworks
                selection: [420]
                showIndicator: true
                multiSelection: false
            }

            Label {
                text: "Checkboxes"
                font.bold: true
            }

            NetworkSelectorView {
                id: networkSelectionView2
                
                Layout.fillWidth: true
                Layout.fillHeight: true
            
                model: NetworksModel.flatNetworks
                showIndicator: true
                multiSelection: true

                selection: [1, 420]
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
                    checked: networkSelectionView.selection.includes(model.chainId)
                    onToggled: {
                        if (checked) {
                            networkSelectionView.selection = [model.chainId]
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
                    checked: networkSelectionView2.selection.includes(model.chainId)
                    onToggled: {
                        if (checked) {
                            const selection = networkSelectionView2.selection
                            selection.push(model.chainId)
                            networkSelectionView2.selection = selection
                        } else {
                            networkSelectionView2.selection = networkSelectionView2.selection.filter((id) => id !== model.chainId)
                        }
                    }
                }
            }
        }
    }
}

// category: Views