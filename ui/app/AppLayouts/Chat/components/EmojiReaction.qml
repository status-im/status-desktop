import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"

Rectangle {
    property alias source: reactionImage.source
    property var closeModal: function () {}
    property int emojiId
    property bool reactedByUser: false
    property bool isHovered: false

    id: root
    width: reactionImage.width + Style.current.halfPadding
    height: width
    color: reactedByUser ? Style.current.secondaryBackground :
                           (isHovered ? Style.current.backgroundHover : Style.current.transparent)
    border.width: reactedByUser ? 1 : 0
    border.color: Style.current.borderTertiary
    radius: Style.current.radius

    SVGImage {
        id: reactionImage
        width: 32
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: !reactedByUser
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onClicked: {
            chatsModel.toggleReaction(SelectedMessage.messageId, emojiId)
            root.closeModal()
        }
    }
}
