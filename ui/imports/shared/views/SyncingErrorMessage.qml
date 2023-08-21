import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    property string primaryText
    property string secondaryText
    property string errorDetails

    spacing: 12

    StatusBaseText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: root.primaryText
        font.pixelSize: 17
        color: Theme.palette.dangerColor1
    }

    ErrorDetails {
        Layout.fillWidth: true
        Layout.leftMargin: 60
        Layout.rightMargin: 60
        Layout.preferredHeight: implicitHeight
        title: root.secondaryText
        details: root.errorDetails
    }
}
