import QtQuick 2.4
import QtQuick.Layouts 1.4

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0
import shared.controls 1.0
import shared.panels 1.0

Badge {
    id: root

    property string repliedMessageContent

    signal replyClicked()

    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin
    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    color: hoverArea.containsMouse ? hoverArea.pressed ? Theme.palette.baseColor3 : Theme.palette.baseColor2 : Style.current.transparent

    RowLayout {
        id: layout

        anchors {
            fill: parent
            leftMargin: 8
            rightMargin: 8
            topMargin: 3
            bottomMargin: 3
        }

        spacing: 4

        StatusIcon {
            source: Style.svg("reply-small-arrow")
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
        }

        StatusBaseText {
            text: repliedMessageContent
            maximumLineCount: 1
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            font.pixelSize: 13
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: hoverArea
        hoverEnabled: true
        anchors.fill: layout
        cursorShape: Qt.PointingHandCursor
        onClicked: root.replyClicked()
    }
}
