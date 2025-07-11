import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as StatusQUtils

import utils
import shared.controls
import shared.panels

Badge {
    id: root

    property string repliedMessageContent

    signal replyClicked()

    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin
    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    color: hoverArea.containsMouse ? hoverArea.pressed ? Theme.palette.baseColor3 : Theme.palette.baseColor2 : Theme.palette.transparent

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
            source: Theme.svg("reply-small-arrow")
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
        }

        StatusBaseText {
            text: repliedMessageContent
            maximumLineCount: 1
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            font.pixelSize: Theme.additionalTextSize
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignVCenter
        }
    }

    StatusMouseArea {
        id: hoverArea
        hoverEnabled: true
        anchors.fill: layout
        cursorShape: Qt.PointingHandCursor
        onClicked: root.replyClicked()
    }
}
