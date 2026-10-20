import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

RowLayout {
    id: root

    required property string icon
    required property string text

    height: d.iconSize
    spacing: Theme.padding

    QtObject {
        id: d

        readonly property int iconSize: 20
    }

    StatusIcon {
        icon: root.icon
        width: d.iconSize
        height: d.iconSize
        color: Theme.palette.directColor1
        Layout.leftMargin: 6
        Layout.alignment: Qt.AlignVCenter
    }

    StatusBaseText {
        text: root.text
        font.pixelSize: Theme.secondaryTextFontSize
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
    }
}
