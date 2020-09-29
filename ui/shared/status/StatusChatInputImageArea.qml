import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../imports"
import "../../shared"

Rectangle {
    id: imageArea
    height: 72

    signal imageRemoved()
    property url imageSource: ""
    color: "transparent"
    
    Image {
        id: chatImage
        property bool hovered: false
        height: 64
        anchors.left: parent.left
        anchors.leftMargin: Style.current.halfPadding
        anchors.top: parent.top
        anchors.topMargin: Style.current.halfPadding
        fillMode: Image.PreserveAspectFit
        mipmap: true
        smooth: false
        antialiasing: true
        source: parent.imageSource
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                chatImage.hovered = true
            }
            onExited: {
                chatImage.hovered = false
            }
        }

        RoundButton {
            id: closeBtn
            implicitWidth: 24
            implicitHeight: 24
            padding: 0
            anchors.top: chatImage.top
            anchors.topMargin: -5
            anchors.right: chatImage.right
            anchors.rightMargin: -Style.current.halfPadding
            visible: chatImage.hovered || hovered
            contentItem: SVGImage {
                source: !closeBtn.hovered ? 
                  "../../app/img/close-filled.svg" : "../../app/img/close-filled-hovered.svg"
                width: closeBtn.width
                height: closeBtn.height
            }
            background: Rectangle {
                color: "transparent"
            }
            onClicked: {
                imageArea.imageRemoved()                
                chatImage.source = ""
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onPressed: mouse.accepted = false
            }
        }
    }

}
