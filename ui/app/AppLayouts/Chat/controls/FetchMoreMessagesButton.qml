import QtQuick 2.13

import StatusQ.Components 0.1

import "../../../../shared/panels"

import utils 1.0

Item {
    id: root
    height: childrenRect.height + Style.current.smallPadding * 2
    anchors.left: parent.left
    anchors.right: parent.right
//    property int nextMessageIndex
//    property string nextMsgTimestamp
    signal clicked()
    signal timerTriggered()
    Timer {
        id: timer
        interval: 3000
        onTriggered: {
            fetchLoaderIndicator.active = false;
            fetchMoreButton.visible = true;
            fetchDate.visible = true;
            root.timerTriggered();
        }
    }

    Separator {
        id: sep1
    }
    Loader {
        id: fetchLoaderIndicator
        anchors.top: sep1.bottom
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.right: parent.right
        active: false
        sourceComponent: StatusLoadingIndicator {
            width: 12
            height: 12
        }
    }
    StyledText {
        id: fetchMoreButton
        font.weight: Font.Medium
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.blue
        //% "↓ Fetch more messages"
        text: qsTrId("load-more-messages")
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: sep1.bottom
        anchors.topMargin: Style.current.smallPadding
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                root.clicked();
                fetchLoaderIndicator.active = true;
                fetchMoreButton.visible = false;
                fetchDate.visible = false;
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
        text: qsTrId("before--1").arg((nextMessageIndex > -1 ? new Date(nextMsgTimestamp * 1) : new Date()).toLocaleString(Qt.locale(globalSettings.locale)))
    }
    Separator {
        anchors.top: fetchDate.bottom
        anchors.topMargin: Style.current.smallPadding
    }
}
