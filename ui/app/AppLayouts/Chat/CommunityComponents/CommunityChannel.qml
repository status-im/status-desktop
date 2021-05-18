import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Rectangle {
    property string name: "channel-name"
    property string channelId: "channel-id"
    property string categoryId: ""
    property var onItemChecked
    property bool isHovered: false
    id: container
    visible: categoryId == ""
    height: visible ? 52 : 0
    width: 425
    anchors.left: parent.left
    border.width: 0
    radius: Style.current.radius
    color: isHovered ? Style.current.backgroundHover : Style.current.transparent

    StatusIdenticon {
        id: channelImage
        height: 36
        width: 36
        chatId: name
        chatName: name
        chatType: Constants.chatTypePublic
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
    }

    StyledText {
        id: channelName
        text: "#" + name
        elide: Text.ElideRight
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        font.pixelSize: 15
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: channelImage.right
        anchors.leftMargin: Style.current.halfPadding
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        hoverEnabled: true
        onEntered: container.isHovered = true
        onExited: container.isHovered = false
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            chk.checked = !chk.checked
        }
    }

    StatusCheckBox  {
        id: chk
        anchors.top: channelImage.top
        anchors.topMargin: 6
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        onClicked: {
            onItemChecked(container.channelId, chk.checked)
        }
    }

}
