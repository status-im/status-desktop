import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../../shared"
import "../../../../../shared/status"
import "../../../../../imports"

Rectangle {
    property bool parentIsHovered: false
    signal hoverChanged(bool hovered)
    property int containerMargin: 2

    id: buttonsContainer
    visible: buttonsContainer.parentIsHovered || isMessageActive
    width: buttonRow.width + buttonsContainer.containerMargin * 2
    height: 36
    radius: Style.current.radius
    color: Style.current.background
    z: 52

    layer.enabled: true
    layer.effect: DropShadow {
        width: buttonsContainer.width
        height: buttonsContainer.height
        x: buttonsContainer.x
        y: buttonsContainer.y + 10
        visible: buttonsContainer.visible
        source: buttonsContainer
        horizontalOffset: 0
        verticalOffset: 2
        radius: 10
        samples: 15
        color: "#22000000"
    }

    MouseArea {
        anchors.fill: buttonsContainer
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        onEntered: {
            buttonsContainer.hoverChanged(true)
        }
        onExited: {
            buttonsContainer.hoverChanged(false)
        }
    }

    Row {
        id: buttonRow
        spacing: buttonsContainer.containerMargin
        anchors.left: parent.left
        anchors.leftMargin: buttonsContainer.containerMargin
        anchors.verticalCenter: buttonsContainer.verticalCenter
        height: parent.height - 2 * buttonsContainer.containerMargin

        StatusIconButton {
            id: emojiBtn
            icon.name: "emoji"
            width: 32
            height: 32
            onClicked: {
                isMessageActive = true
                clickMessage(false, false, false, null, true)
                messageContextMenu.x = buttonsContainer.x + buttonsContainer.width - messageContextMenu.width

                // The Math.max is to make sure that the menu is rendered
                messageContextMenu.y -= Math.max(messageContextMenu.emojiContainer.height, 56) + Style.current.padding
            }
            onHoveredChanged: {
                buttonsContainer.hoverChanged(this.hovered)
            }

            StatusToolTip {
              visible: emojiBtn.hovered
              text: qsTr("Add reaction")
            }
        }

        StatusIconButton {
            id: replyBtn
            icon.name: "reply"
            width: 32
            height: 32
            onClicked: {
                SelectedMessage.set(messageId, fromAuthor);
                showReplyArea()
            }
            onHoveredChanged: {
                buttonsContainer.hoverChanged(this.hovered)
            }

            StatusToolTip {
              visible: replyBtn.hovered
              text: qsTr("Reply")
            }
        }
    }
}
