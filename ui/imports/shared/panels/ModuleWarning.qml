import QtQuick 2.14
import QtQuick.Controls 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root
    implicitHeight: visible ? 32 : 0
    color: Theme.palette.dangerColor1

    property string text: ""
    property string btnText: ""
    property bool closing: false
    property int progressValue: -1 // 0..100, -1 not visible
    property alias closeBtnVisible: closeImg.visible
    property var onClick: function() {}

    signal closed()
    signal linkActivated(string link)

    function close() {
        closeBtn.clicked(null)
        closed();
    }

    Row {
        spacing: Style.current.halfPadding
        anchors.centerIn: parent

        StatusBaseText {
            text: root.text
            font.pixelSize: 13
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.palette.white
            linkColor: color
            onLinkActivated: root.linkActivated(link)
            HoverHandler {
                id: handler1
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: handler1.hovered && parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }

        Button {
            height: 24
            padding: 6
            visible: !!text
            text: root.btnText
            anchors.verticalCenter: parent.verticalCenter
            contentItem: StatusBaseText {
                text: parent.text
                font.pixelSize: 13
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.white
            }
            background: Rectangle {
                radius: 4
                border.color: Theme.palette.white
                color: "#19FFFFFF"
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
            }
            onClicked: root.onClick()
        }
    }

    StatusBaseText {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: progressBar.left
        anchors.rightMargin: Style.current.halfPadding
        text: qsTr("%1%").arg(progressBar.value)
        visible: progressBar.visible
        font.pixelSize: 12
        verticalAlignment: Text.AlignVCenter
        color: Theme.palette.white
    }

    ProgressBar {
        id: progressBar
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: closeImg.left
        anchors.rightMargin: Style.current.bigPadding
        from: 0
        to: 100
        visible: root.progressValue > -1
        value: root.progressValue
        background: Rectangle {
            implicitWidth: 64
            implicitHeight: 8
            radius: 8
            color: "transparent"
            border.width: 1
            border.color: Theme.palette.white
        }
        contentItem: Rectangle {
            width: progressBar.width*progressBar.position
            implicitHeight: 8
            radius: 8
            color: Theme.palette.white
        }
    }

    StatusIcon {
        id: closeImg
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        icon: "close-circle"
        color: Theme.palette.white
        height: 20
        width: 20
    }
    MouseArea {
        id: closeBtn
        anchors.fill: closeImg
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.closing = true
        }
    }

    ParallelAnimation {
        running: root.closing
        PropertyAnimation { target: root; property: "visible"; to: false; }
        PropertyAnimation { target: root; property: "y"; to: -1 * root.height }
        onRunningChanged: {
            if(!running){
                root.closing = false;
                root.y = 0;
                root.closed();
            }
        }
    }
}
