import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Models 1.0
import utils 1.0
import AppLayouts.Communities.controls 1.0

Item {
    id: root

    readonly property var modelData: [
        {
            name: "Optimism",
            icon: Style.svg(ModelsData.networks.optimism),
            amount: 300,
            infiniteAmount: false
        },
        {
            name: "Arbitrum",
            icon: Style.svg(ModelsData.networks.arbitrum),
            amount: 400,
            infiniteAmount: false
        },
        {
            name: "Hermez",
            icon: Style.svg(ModelsData.networks.hermez),
            amount: 0,
            infiniteAmount: true
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
                text: `current amount infinite: ${comboBox.currentInfiniteAmount}`
            }
        }
    }
}
