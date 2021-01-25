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
            chatLogView.chatButtonsHovered = true
        }
        onExited: {
            buttonsContainer.hoverChanged(false)
            chatLogView.chatButtonsHovered = false
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
            }
            onHoveredChanged: {
                chatLogView.chatButtonsHovered = this.hovered
                buttonsContainer.hoverChanged(this.hovered)
            }

            StatusToolTip {
              visible: emojiBtn.hovered
              text: qsTr("Add reaction")
              width: 115
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
                chatLogView.chatButtonsHovered = this.hovered
                buttonsContainer.hoverChanged(this.hovered)
            }

            StatusToolTip {
              visible: replyBtn.hovered
              text: qsTr("Reply")
              width: 75
            }
        }
    }
}
