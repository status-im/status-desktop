import QtQuick 2.15
import QtQuick.Layouts 1.15

import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

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
