import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"

SVGImage {
    property var closeModal: function () {}
    property int emojiId
    id: reactionImage
    width: 32
    fillMode: Image.PreserveAspectFit

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            chatsModel.toggleReaction(SelectedMessage.messageId, emojiId)
            reactionImage.closeModal()
        }
    }
}
