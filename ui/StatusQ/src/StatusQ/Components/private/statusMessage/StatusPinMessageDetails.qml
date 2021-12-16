import QtQuick 2.13
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Loader {
    property string pinnedMsgInfoText: ""
    property string pinnedBy: ""

    active: visible

    sourceComponent: Rectangle {
        height: 24
        width: layout.width + 16
        color: Theme.palette.pinColor2
        radius: 12
        RowLayout {
            id: layout
            anchors.centerIn: parent
            StatusIcon {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                color: Theme.palette.pinColor1
                icon: "tiny/pin"
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: -4
                color: Theme.palette.directColor1
                font.pixelSize: 13
                text: pinnedMsgInfoText
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: -4
                color: Theme.palette.directColor1
                font.pixelSize: 13
                font.weight: Font.Medium
                text: pinnedBy
            }
        }
    }
}
