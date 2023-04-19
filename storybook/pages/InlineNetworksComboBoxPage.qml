import QtQuick 2.15
import QtQuick.Controls 2.15

import Models 1.0
import utils 1.0
import AppLayouts.Chat.controls.community 1.0

Item {
    id: root

    readonly property var modelData: [
        {
            name: "Optimism",
            icon: Style.svg(ModelsData.networks.optimism),
            amount: "300"
        },
        {
            name: "Arbitrum",
            icon: Style.svg(ModelsData.networks.arbitrum),
            amount: "400"
        },
        {
            name: "Hermez",
            icon: Style.svg(ModelsData.networks.hermez),
            amount: "500"
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

    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: implicitHeight / 2

        RadioButton {
            id: singleItemRadioButton
            text: "single item model"
        }
        RadioButton {
            text: "multiple items model"
            checked: true
        }
    }
}
