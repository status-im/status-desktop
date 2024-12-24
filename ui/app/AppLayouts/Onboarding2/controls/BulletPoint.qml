import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

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
