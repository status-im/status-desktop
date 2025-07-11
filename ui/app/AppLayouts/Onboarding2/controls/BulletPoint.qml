import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

RowLayout {
    property string text
    property bool checked

    spacing: 6
    StatusIcon {
        Layout.preferredWidth: 20
        Layout.preferredHeight: 20
        icon: parent.checked ? "check-circle" : "close-circle"
        color: parent.checked ? Theme.palette.successColor1 : Theme.palette.dangerColor1
    }
    StatusBaseText {
        Layout.fillWidth: true
        text: parent.text
        font.pixelSize: Theme.additionalTextSize
    }
}
