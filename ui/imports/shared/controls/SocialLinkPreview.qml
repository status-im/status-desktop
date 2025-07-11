import QtQuick
import QtQuick.Layouts

import utils

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

Rectangle {
    id: root

    property string text
    property string url
    property string icon

    implicitWidth: layout.implicitWidth + 16
    implicitHeight: layout.implicitHeight + 10

    color: "transparent"
    border {
        width: 1
        color: Theme.palette.baseColor2
    }
    radius: height/2

    RowLayout {
        id: layout

        anchors.centerIn: parent

        StatusIcon {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            icon: root.icon
            visible: icon !== ""
            color: Theme.palette.directColor1
        }

        StatusBaseText {
            Layout.maximumWidth: 150
            text: root.text
            color: Theme.palette.directColor4
            font.weight: Font.Medium
            elide: Text.ElideMiddle
        }
    }

    StatusToolTip {
        id: toolTip
        text: root.url
        visible: mouseArea.containsMouse
    }

    StatusMouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Global.openLink(root.url)
    }
}
