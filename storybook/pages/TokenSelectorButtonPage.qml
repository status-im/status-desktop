import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.1

import AppLayouts.Wallet.controls 1.0
import StatusQ.Core.Theme 0.1
import utils 1.0

Pane {
    padding: 0

    Rectangle {
        anchors.fill: parent
        color: Theme.palette.baseColor3
    }

    Rectangle {
        anchors.centerIn: parent

        width: 300
        height: 60
        color: "transparent"
        border.color: "lightgray"

        RowLayout {
            anchors.fill: parent

            TokenSelectorButton {
                id: panel

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                Layout.maximumWidth: implicitWidth

                selected: selectionCheckBox.checked
                forceHovered: forceHoveredCheckBox.checked
                size: smallCheckBox.checked ? TokenSelectorButton.Size.Small :
                                              TokenSelectorButton.Size.Normal


                name: "My token" + (longNameCheckBox.checked ? " long name" : "")
                icon: Constants.tokenIcon("CFI")
            }
        }
    }

    ColumnLayout {
        CheckBox {
            id: selectionCheckBox

            text: "selected"
        }

        CheckBox {
            id: longNameCheckBox

            text: "long name"
        }

        CheckBox {
            id: forceHoveredCheckBox

            text: "force hovered"
        }


        CheckBox {
            id: smallCheckBox

            text: "small"
        }
    }

    Settings {
        property alias selected: selectionCheckBox.checked
        property alias longName: longNameCheckBox.checked
        property alias forceHovered: forceHoveredCheckBox.checked
    }
}

// category: Controls
