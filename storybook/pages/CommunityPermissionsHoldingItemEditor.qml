import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import AppLayouts.Chat.controls.community 1.0

ColumnLayout {
    id: root

    property string panelText

    property int type
    property string key
    property string amountText

    property var assetKeys: []
    property var collectibleKeys: []

    QtObject {
        id: d

        readonly property bool ensLayout: root.type === HoldingTypes.Type.Ens

        readonly property var holdingTypesModel: [
            { value: HoldingTypes.Type.Asset, text: "Asset" },
            { value: HoldingTypes.Type.Collectible, text: "Collectible" },
            { value: HoldingTypes.Type.Ens, text: "ENS" }
        ]
    }

    Label {
        Layout.fillWidth: true
        text: root.panelText
        font.weight: Font.Bold
    }

    ColumnLayout {
        Label {
            Layout.fillWidth: true
            text: "Type"
        }

        ComboBox {
            id: holdingTypeComboBox

            Layout.fillWidth: true

            model: d.holdingTypesModel
            textRole: "text"
            valueRole: "value"

            onActivated: root.type = currentValue
            Component.onCompleted: currentIndex = indexOfValue(root.type)
        }
    }

    RowLayout {
        ColumnLayout {
            Label {
                Layout.fillWidth: true
                text: d.ensLayout ? "Domain" : "Key"
            }

            ComboBox {
                Layout.fillWidth: true

                visible: !d.ensLayout
                model: root.type === HoldingTypes.Type.Asset
                       ? root.assetKeys : root.collectibleKeys

                onActivated: root.key = currentText

                Component.onCompleted: currentIndex = find(root.key)
            }

            TextField {
                Layout.fillWidth: true

                visible: d.ensLayout
                text: root.key
                onTextChanged: root.key = text
            }
        }

        ColumnLayout {
            visible: !d.ensLayout

            Label {
                Layout.fillWidth: true
                text: "Amount"
            }

            TextField {
                Layout.fillWidth: true
                text: root.amountText
                onTextChanged: root.amountText = text
            }
        }
    }

    MenuSeparator {
        Layout.fillWidth: true
    }
}
