import QtQuick
import QtQuick.Layouts

import shared.panels

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import utils

ColumnLayout {
    id: root

    property alias text: textComponent.text

    signal clicked

    spacing: Theme.halfPadding

    Separator {
        Layout.fillWidth: true
        Layout.topMargin: Theme.padding
        Layout.bottomMargin: Theme.padding
    }

    StatusBaseText {
        id: textComponent

        Layout.alignment: Qt.AlignHCenter

        font.pixelSize: Theme.additionalTextSize
        text: ""
    }

    StatusFlatButton {
        Layout.alignment: Qt.AlignHCenter

        font.pixelSize: Theme.additionalTextSize
        text: qsTr("Add accounts to showcase")

        onClicked: root.clicked()
    }
}
