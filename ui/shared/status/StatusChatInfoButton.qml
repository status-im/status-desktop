import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../imports"
import "../../shared"
import "../../shared/status"

Button {
    id: control

    property string chatId
    property string chatName
    property int chatType
    property string identicon
    property int identiconSize: 40
    property bool isCompact: false

    implicitHeight: 48
    implicitWidth: content.width + 8
    leftPadding: 4
    rightPadding: 4

    contentItem: StatusChatInfo {
        id: content
        chatId: control.chatId
        chatName: control.chatName
        chatType: control.chatType
        identicon: control.identicon
        identiconSize: control.identiconSize
        isCompact: control.isCompact
    }

    background: Rectangle {
        color: control.hovered ? Style.current.topBarChatInfoColor : "transparent"
        radius: Style.current.radius
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}
