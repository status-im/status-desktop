import QtQuick 2.14
import QtQuick.Controls 2.14

import utils 1.0

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.panels 1.0
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import Storybook 1.0

import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    QtObject {
        id: d

        property var dummyTx: ({
                                   id: 0xb501e3042105c382a498819b07aba58de3422984e1150655c1583bd1aae144ef,
                                   txType: "erc20",
                                   address: 0x9d41ac74e7d1f981e98f4ec0d631cde0857a2b9c,
                                   blockNumber: 0x7b7935,
                                   blockHash: 0,
                                   timestamp: 1670419848,
                                   nonce: 0x36,
                                   txStatus: 0x1,
                                   chainId: 5,
                                   txHash: 0x82de33a9e81f7c06ea03ad742bc666c4eacb7ec771bac4544ef70a12b2c46d04,
                                   symbol: "ETH",
                               })
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Column {
            anchors.centerIn: parent
            spacing: 100
            StatusTxProgressBar {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 500
                error: failureCheckBox.checked
                isLayer1: mainnetCheckbox.checked
                confirmations: confirmationsSlider.value
                duration: durationSlider.to
                progress: durationSlider.value
                chainName: isLayer1 ? "Mainnet" :"Optimism"
            }

            Rectangle {
                width: root.width
                height: 400
                border.width: 2
                WalletTxProgressBlock {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    width: 500
                    error: failureCheckBox.checked
                    isLayer1: mainnetCheckbox.checked
                    confirmations: confirmationsSlider.value
                    duration: durationSlider.to
                    progress: durationSlider.value
                    chainName: isLayer1 ? "Mainnet" :"Optimism"
                    confirmationTimeStamp: 1670419848
                    finalisationTimeStamp: 1670419848
                    failedTimeStamp: 1670419848
                }
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
        Column {
            CheckBox {
                id: mainnetCheckbox
                text: "Mainnet"
                checked: true
            }
            CheckBox {
                id: failureCheckBox
                text: "Failed"
                checked: false
            }
            Slider {
                id: confirmationsSlider
                width: 600
                value: 0
                from: 0
                to: 1000
                stepSize: 1
                Text {
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Confirmations = " + confirmationsSlider.value
                }
            }
            StatusInput {
                id: duration
                label: "Duration for finalisation"
                text: "7"
                visible: !mainnetCheckbox.checked && !failureCheckBox.checked
            }
            Slider {
                id: durationSlider
                width: 600
                value: 0
                from: 0
                to: Number(duration.text)*24
                stepSize: 1
                Text {
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Finalisation = " + durationSlider.value
                }
                visible: !mainnetCheckbox.checked && !failureCheckBox.checked
            }
        }
    }
}
