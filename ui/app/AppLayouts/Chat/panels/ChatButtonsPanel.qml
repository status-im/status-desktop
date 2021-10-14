import QtQuick 2.13
import QtGraphicalEffects 1.13

import "../../../../shared/status"

import StatusQ.Controls 0.1 as StatusQ
import utils 1.0

Rectangle {
    id: buttonsContainer
    property bool parentIsHovered: false
    property int containerMargin: 2
    property int contentType: 2
    property var messageContextMenu
    property bool showMoreButton: true
    property bool activityCenterMessage
    property string fromAuthor
    property alias editBtnActive: editBtn.active
    signal hoverChanged(bool hovered)
    signal setMessageActive(string messageId, bool active)
    signal clickMessage(bool isProfileClick, bool isSticker, bool isImage, var image, bool emojiOnly)

    visible: !activityCenterMessage &&
             (buttonsContainer.parentIsHovered || isMessageActive)
             && contentType !== Constants.transactionType
    width: buttonRow.width + buttonsContainer.containerMargin * 2
    height: 36
    radius: Style.current.radius
    color: Style.current.modalBackground
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
                setMessageActive(messageId, true)
                // Set parent, X & Y positions for the messageContextMenu
                buttonsContainer.messageContextMenu.parent = buttonsContainer
                buttonsContainer.messageContextMenu.setXPosition = function() { return (-Math.abs(buttonsContainer.width - buttonsContainer.messageContextMenu.emojiContainer.width))}
                buttonsContainer.messageContextMenu.setYPosition = function() { return (-buttonsContainer.messageContextMenu.height - 4)}
                clickMessage(false, false, false, null, true)
            }
            onHoveredChanged: {
                buttonsContainer.hoverChanged(this.hovered)
            }

            StatusQ.StatusToolTip {
              visible: emojiBtn.hovered
              //% "Add reaction"
              text: qsTrId("add-reaction")
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
                if (messageContextMenu.closeParentPopup) {
                    messageContextMenu.closeParentPopup()
                }
            }
            onHoveredChanged: {
                buttonsContainer.hoverChanged(this.hovered)
            }

            StatusQ.StatusToolTip {
              visible: replyBtn.hovered
              //% "Reply"
              text: qsTrId("message-reply")
            }
        }

        Loader {
            id: editBtn
            sourceComponent: StatusIconButton {
                id: btn
                icon.name: "edit-message"
                width: 32
                height: 32
                onClicked: {
                    isEdit = true
                }
                onHoveredChanged: {
                    buttonsContainer.hoverChanged(btn.hovered)
                }

                StatusQ.StatusToolTip {
                    visible: btn.hovered
                    //% "Edit"
                    text: qsTrId("edit")
                }
            }
        }

        StatusIconButton {
            id: otherBtn
            visible: showMoreButton
            icon.name: "dots-icon"
            width: 32
            height: 32
            onClicked: {
                if (typeof isMessageActive !== "undefined") {
                    setMessageActive(messageId, true)
                }
                // Set parent, X & Y positions for the messageContextMenu
                buttonsContainer.messageContextMenu.parent = buttonsContainer
                buttonsContainer.messageContextMenu.setXPosition = function() { return (-Math.abs(buttonsContainer.width - 176))}
                buttonsContainer.messageContextMenu.setYPosition = function() { return (-buttonsContainer.messageContextMenu.height - 4)}
                clickMessage(false, isSticker, false, null, false, true);
            }
            onHoveredChanged: {
                buttonsContainer.hoverChanged(this.hovered)
            }
            StatusQ.StatusToolTip {
                visible: otherBtn.hovered
                //% "More"
                text: qsTrId("more")
            }
        }
    }
}
