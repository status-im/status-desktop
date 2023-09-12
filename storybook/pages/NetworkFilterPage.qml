import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13

import Storybook 1.0
import Models 1.0

import AppLayouts.Wallet.controls 1.0

SplitView {
    id: root
    Logs { id: logs }

    readonly property string ethereumName : "Ethereum Mainnet"
    readonly property string optimismName : "Optimism"
    readonly property string arbitrumName : "Arbitrum"

    SplitView {

        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            id: container

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            Rectangle {
                width: 800
                height: 200
                border.width: 1
                anchors.centerIn: parent

                NetworkFilter {
                    id: networkFilter

                    anchors.centerIn: parent
                    width: 200

                    layer1Networks: NetworksModel.layer1Networks
                    layer2Networks: NetworksModel.layer2Networks
                    enabledNetworks: NetworksModel.enabledNetworks
                    allNetworks: enabledNetworks

                    multiSelection: multiSelectionCheckBox.checked

                    onToggleNetwork: {

                        logs.logEvent("onToggleNetwork: " + network.chainName)
                        if(network.chainName === root.ethereumName)
                            ethRadioBtn.checked = true

                        else if(network.chainName === root.optimismName)
                            optRadioBtn.checked = true

                        else if(network.chainName === root.arbitrumName)
                            arbRadioBtn.checked = true
                    }
                }
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
                checked: true
                onCheckedChanged: if(!checked) ethRadioBtn.checked = true
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
                    onCheckedChanged: if(checked) networkFilter.setChain(NetworksModel.ethNet)
                }
                RadioButton {
                    id: optRadioBtn

                    text: root.optimismName
                    onCheckedChanged: if(checked) networkFilter.setChain(NetworksModel.optimismNet)
                }
                RadioButton {
                    id: arbRadioBtn

                    text: root.arbitrumName
                    onCheckedChanged: if(checked) networkFilter.setChain(NetworksModel.arbitrumNet)
                }
            }
        }
    }
}

// category: Components
