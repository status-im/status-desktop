import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.controls 1.0

Column {
    spacing: 57

    StatusInput {
        id: codeInput
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.topMargin: 70
        label: qsTr("Paste sync code")
        input.placeholderText: qsTr("eg. %1").arg("0x2Ef19")
        input.font: Theme.palette.monoFont.name
        input.placeholderFont: input.font
        input.rightComponent: StatusButton {
            size: StatusBaseButton.Size.Tiny
            enabled: codeInput.input.edit.canPaste
            onClicked: codeInput.input.edit.paste()
            text: qsTr("Paste")
        }
    }

    StatusSyncingInstructions {
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
