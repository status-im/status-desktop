import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Core.Utils

import shared.controls

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
        font.pixelSize: Theme.secondaryAdditionalTextSize
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
