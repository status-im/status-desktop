import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qt.labs.settings

import AppLayouts.Wallet.controls
import StatusQ.Core.Theme
import utils

Pane {
    padding: 0

    Rectangle {
        anchors.fill: parent
        color: Theme.palette.baseColor3
    }

    RowLayout {
        anchors.centerIn: parent

        width: 400
        height: 60

        TokenSelectorCompactButton {
            id: panel

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            selected: selectionCheckBox.checked

            name: "My token" + (longNameCheckBox.checked
                                ? " long".repeat(10) : "")
            subname: "MTKN"
            icon: Constants.tokenIcon("CFI")
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
    }

    Settings {
        property alias selected: selectionCheckBox.checked
        property alias longName: longNameCheckBox.checked
    }
}

// category: Controls
