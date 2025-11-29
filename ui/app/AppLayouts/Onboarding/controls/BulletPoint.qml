import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

RowLayout {
    id: root

    property string text
    property bool checked
    property int wrapMode: Text.WordWrap

    spacing: 6
    StatusIcon {
        Layout.preferredWidth: 20
        Layout.preferredHeight: 20
        icon: root.checked ? "check-circle" : "close-circle"
        color: root.checked ? Theme.palette.successColor1 : Theme.palette.dangerColor1
    }
    StatusBaseText {
        Layout.fillWidth: true
        text: root.text
        font.pixelSize: Theme.additionalTextSize
        wrapMode: root.wrapMode
    }
}
