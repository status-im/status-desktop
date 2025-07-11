import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Communities.controls
import utils

ColumnLayout {
    id: root

    property int type
    property string key
    property string amountText

    property var assetKeys: []
    property var collectibleKeys: []

    QtObject {
        id: d

        readonly property bool ensLayout: root.type === Constants.TokenType.ENS

        readonly property var holdingTypesModel: [
            { value: Constants.TokenType.ERC20, text: "Asset" },
            { value: Constants.TokenType.ERC721, text: "Collectible" },
            { value: Constants.TokenType.ENS, text: "ENS" }
        ]
    }

    onTypeChanged: {
        Qt.callLater(() => {
            if (d.ensLayout) {
                root.key = "*.eth"
                return
            }

            const idx = holdingComboBox.find(root.key)
            holdingComboBox.currentIndex = idx === -1 ? 0 : idx
            root.key = holdingComboBox.currentText
        })
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
                id: holdingComboBox
                Layout.fillWidth: true

                visible: !d.ensLayout
                model: root.type === Constants.TokenType.ERC20
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
}
