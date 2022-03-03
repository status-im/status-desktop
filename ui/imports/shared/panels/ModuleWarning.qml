import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import "../"
import "./"

Rectangle {
    id: root
    height: visible ? 32 : 0
    implicitHeight: height
    color: Style.current.red

    property string text: ""
    property string btnText: ""
    property int btnWidth: 58
    property bool closing: false

    property var onClick: function() {}

    signal closed()

    function close() {
        closeBtn.clicked(null)
        closed();
    }

    Row {
        spacing: Style.current.halfPadding
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        StyledText {
            text: root.text
            font.pixelSize: 13
            anchors.verticalCenter: parent.verticalCenter
            color: Style.current.white
        }

        Button {
            width: btnWidth
            height: 24
            contentItem: Item {
                anchors.fill: parent
                Text {
                    text: btnText
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    font.family: Style.current.fontRegular.name
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Style.current.white
                }
            }
            background: Rectangle {
                radius: 4
                anchors.fill: parent
                border.color: Style.current.white
                color: "#19FFFFFF"
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: root.onClick()
            }
        }
    }

    SVGImage {
        id: closeImg
        anchors.top: parent.top
        anchors.topMargin: 6
        anchors.right: parent.right
        anchors.rightMargin: 18
        source: Style.svg("close-white")
        height: 20
        width: 20
    }
    ColorOverlay {
        anchors.fill: closeImg
        source: closeImg
        color: Style.current.white
        opacity: 0.7
    }
    MouseArea {
        id: closeBtn
        anchors.fill: closeImg
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            closing = true
        }
    }

    ParallelAnimation {
        running: closing
        PropertyAnimation { target: root; property: "visible"; to: false; }
        PropertyAnimation { target: root; property: "y"; to: -1 * root.height }
        onRunningChanged: {
            if(!running){
                closing = false;
                root.y = 0;
                root.closed();
            }
        }
    }
}
