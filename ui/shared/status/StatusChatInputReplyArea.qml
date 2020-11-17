import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../imports"
import "../../shared"

Rectangle {
    id: root
    height: 50
    color: Style.current.lightGrey
    radius: 16
    clip: true

    property string userName: ""
    property string message : ""
    property string identicon: ""

    signal closeButtonClicked()

    Rectangle {
        color: parent.color
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        height: parent.height / 2
        width: 32
        radius: Style.current.radius
    }

    StyledText {
        id: replyToUsername
        text: "↪ " + userName
        color: Style.current.black
        anchors.top: parent.top
        anchors.topMargin: Style.current.halfPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        font.pixelSize: 13
        font.weight: Font.Medium
    }

    StyledText {
        id: replyText
        text: Emoji.parse(message)
        anchors.left: replyToUsername.left
        anchors.top: replyToUsername.bottom
        anchors.topMargin: 2
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.bottom: parent.bottom
        elide: Text.ElideRight
        font.pixelSize: 13
        font.weight: Font.Normal
        // Eliding only works for PlainText: https://bugreports.qt.io/browse/QTBUG-16567
        textFormat: Text.PlainText
        color: Style.current.black
    }

    RoundButton {
        id: closeBtn
        implicitWidth: 20
        implicitHeight: 20
        radius: 10
        padding: 0
        anchors.top: parent.top
        anchors.topMargin: 4
        anchors.right: parent.right
        anchors.rightMargin: 4
        contentItem: SVGImage {
            id: iconImg
            source: "../../app/img/close.svg"
            width: closeBtn.width
            height: closeBtn.height

            ColorOverlay {
                anchors.fill: iconImg
                source: iconImg
                color: Style.current.black
                antialiasing: true
            }
        }
        background: Rectangle {
            color: "transparent"
            width: closeBtn.width
            height: closeBtn.height
            radius: closeBtn.radius
        }
        onClicked: {
            root.userName = ""
            root.message = ""
            root.identicon = ""
            root.closeButtonClicked()
        }
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onPressed: mouse.accepted = false
        }
    }

}
