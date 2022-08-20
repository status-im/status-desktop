import QtQuick 2.13
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Loader {
    property string pinnedMsgInfoText: ""
    property string pinnedBy: ""

    active: visible

    sourceComponent: Control {
        verticalPadding: 3
        leftPadding: 2
        rightPadding: 6

        background: Rectangle {
            readonly property color translucentColor: Theme.palette.pinColor2

            implicitWidth: 24
            implicitHeight: 24
            color: Qt.rgba(translucentColor.r,
                           translucentColor.g,
                           translucentColor.b, 1)
            opacity: translucentColor.a
            layer.enabled: true
            radius: 12

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: parent.width / 2
                height: parent.height / 2
                color: parent.color
                radius: 4
            }
        }

        contentItem: RowLayout {
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
