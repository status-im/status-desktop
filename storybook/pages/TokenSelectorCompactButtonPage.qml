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
