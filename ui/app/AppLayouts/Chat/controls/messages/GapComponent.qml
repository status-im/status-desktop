import QtQuick 2.13
import "../../../../../shared"
import "../../../../../shared/panels"
import "../../../../../shared/status/core"

import utils 1.0

Item {
    id: root
    height: childrenRect.height + Style.current.smallPadding * 2
    anchors.left: parent.left
    anchors.right: parent.right
    signal clicked()
    Separator {
        id: sep1
    }
    StyledText {
        id: fetchMoreButton
        font.weight: Font.Medium
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.blue
        //% "↓ "
        //% "Fetch messages"
        text: qsTrId("fetch-messages")
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: sep1.bottom
        anchors.topMargin: Style.current.smallPadding
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                root.clicked();
            }
        }
    }
    StyledText {
        id: fetchDate
        anchors.top: fetchMoreButton.bottom
        anchors.topMargin: 3
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: Style.current.secondaryText
        //% "before %1"
        //% "Between %1 and %2"
        text: qsTrId("between--1-and--2").arg(new Date(root.gapFrom*1000)).arg(new Date(root.gapTo*1000))
    }
    Separator {
        anchors.top: fetchDate.bottom
        anchors.topMargin: Style.current.smallPadding
    }
}
