import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13

import Storybook 1.0
import Models 1.0

import SortFilterProxyModel 0.2

import AppLayouts.stores 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.views 1.0

SplitView {
    id: root
    Logs { id: logs }

    readonly property string ethereumName : "Mainnet"
    readonly property string optimismName : "Optimism"
    readonly property string arbitrumName : "Arbitrum"

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            id: container

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            NetworkFilter {
                id: networkFilter

                anchors.centerIn: parent

                flatNetworks: NetworksModel.flatNetworks

                multiSelection: multiSelectionCheckBox.checked
                showAllSelectedText: ctrlShowAllSelectedText.checked
                showTitle: ctrlShowTitle.checked
                selectionAllowed: selectionAllowedCheckBox.checked
                showSelectionIndicator: (ctrlShowCheckBoxes.checked && multiSelection) || (ctrlShowRadioButtons.checked && !multiSelection)
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            spacing: 16

            CheckBox {
                id: multiSelectionCheckBox
                text: "Multi selection"
                checked: false
            }

            CheckBox {
                id: ctrlShowTitle
                text: "Show title text"
                checked: true
            }

            CheckBox {
                id: ctrlShowCheckBoxes
                visible: multiSelectionCheckBox.checked
                text: "Show checkboxes"
                checked: true
            }

            CheckBox {
                id: ctrlShowRadioButtons
                visible: !multiSelectionCheckBox.checked
                text: "Show radio buttons"
                checked: true
            }

            CheckBox {
                id: ctrlShowAllSelectedText
                text: "Show 'All networks' text"
                visible: multiSelectionCheckBox.checked
                checked: true
            }

            CheckBox {
                id: selectionAllowedCheckBox
                text: "Selection allowed"
                checked: true
            }

            ColumnLayout {
                visible: !multiSelectionCheckBox.checked
                Label {
                    Layout.fillWidth: true
                    text: "Chain Id:"
                }

                RadioButton {
                    id: ethRadioBtn

                    text: root.ethereumName
                    checked: networkFilter.selection.includes(NetworksModel.ethNet)
                    onToggled: networkFilter.selection = [NetworksModel.ethNet]
                }
                RadioButton {
                    id: optRadioBtn

                    text: root.optimismName
                    checked: networkFilter.selection.includes(NetworksModel.optimismNet)
                    onToggled: networkFilter.selection = [NetworksModel.optimismNet]
                }
                RadioButton {
                    id: arbRadioBtn

                    text: root.arbitrumName
                    checked: networkFilter.selection.includes(NetworksModel.arbitrumNet)
                    onToggled: networkFilter.selection = [NetworksModel.arbitrumNet]
                }
            }
        }
    }
}

// category: Components

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=13179-346563&mode=design&t=RUkJVqqhgam32C1S-0
