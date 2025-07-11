import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Models
import utils

import StatusQ.Core.Theme

import AppLayouts.Communities.controls

Item {
    id: root

    readonly property var modelData: [
        {
            name: "Optimism",
            icon: Theme.svg(ModelsData.networks.optimism),
            amount: "300",
            multiplierIndex: 0,
            infiniteAmount: false
        },
        {
            name: "Arbitrum",
            icon: Theme.svg(ModelsData.networks.arbitrum),
            amount: "400000",
            multiplierIndex: 3,
            infiniteAmount: false
        },
        {
            name: "Hermez",
            icon: Theme.svg(ModelsData.networks.hermez),
            amount: "0",
            multiplierIndex: 0,
            infiniteAmount: true
        },
        {
            name: "Ethereum",
            icon: Theme.svg(ModelsData.networks.ethereum),
            amount: "12" + "0".repeat(18),
            multiplierIndex: 18,
            infiniteAmount: false
        }
    ]

    ListModel {
        id: singleItemModel

        Component.onCompleted: append(modelData[0])
    }

    ListModel {
        id: multipleItemsModel

        Component.onCompleted: append(modelData)
    }

    InlineNetworksComboBox {
        id: comboBox

        anchors.centerIn: parent

        width: 300

        model: singleItemRadioButton.checked ? singleItemModel
                                             : multipleItemsModel
    }
    Pane {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        ColumnLayout {
            Row {
                Layout.alignment: Qt.AlignHCenter

                RadioButton {
                    id: singleItemRadioButton
                    text: "single item model"
                }
                RadioButton {
                    text: "multiple items model"
                    checked: true
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: `current name: ${comboBox.control.displayText}`
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: `current amount: ${comboBox.currentAmount}`
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: `current multiplier index: ${comboBox.currentMultiplierIndex}`
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: `current amount infinite: ${comboBox.currentInfiniteAmount}`
            }
        }
    }
}

// category: Components
