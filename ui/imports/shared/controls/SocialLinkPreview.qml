import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: root

    property string text
    property string url
    property int linkType: 1
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

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Global.openLink(root.url)
    }
}
