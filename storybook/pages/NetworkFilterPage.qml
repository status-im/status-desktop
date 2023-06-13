import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13

import Storybook 1.0
import Models 1.0

import AppLayouts.Wallet.controls 1.0

SplitView {
    id: root
    Logs { id: logs }

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
                    testNetworks: NetworksModel.testNetworks
                    enabledNetworks: NetworksModel.enabledNetworks
                    allNetworks: enabledNetworks

                    multiSelection: multiSelectionCheckBox.checked

                    onToggleNetwork: logs.logEvent("onToggleNetwork: " + network.chainName)
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

                    text: "Ethereum Mainnet"
                    onCheckedChanged: if(checked) networkFilter.setChain(NetworksModel.ethNet)
                }
                RadioButton {
                    text: "Optimism"
                    onCheckedChanged: if(checked) networkFilter.setChain(NetworksModel.optimismNet)
                }
                RadioButton {
                    text: "Arbitrum"
                    onCheckedChanged: if(checked) networkFilter.setChain(NetworksModel.arbitrumNet)
                }
                RadioButton {
                    text: "Hermez"
                    onCheckedChanged: if(checked) networkFilter.setChain(NetworksModel.hermezNet)
                }
                RadioButton {
                    text: "Testnet"
                    onCheckedChanged: if(checked) networkFilter.setChain(NetworksModel.testnetNet)
                }
                RadioButton {
                    text: "Custom"
                    onCheckedChanged: if(checked) networkFilter.setChain(NetworksModel.customNet)
                }
                RadioButton {
                    text: "Undefined"
                    onCheckedChanged: if(checked) networkFilter.setChain()
                }
                RadioButton {
                    text: "Not existing network id"
                    onCheckedChanged: if(checked) networkFilter.setChain(77)
                }
            }
        }
    }
}
