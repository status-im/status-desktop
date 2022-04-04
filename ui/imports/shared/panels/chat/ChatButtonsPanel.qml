import QtQuick 2.13
import QtGraphicalEffects 1.13

import StatusQ.Controls 0.1

import utils 1.0
import shared.popups 1.0

Rectangle {
    id: buttonsContainer
    property bool parentIsHovered: false
    property bool isChatBlocked: false
    property int containerMargin: 2
    property int contentType: 2
    property bool isCurrentUser: false
    property bool isMessageActive: false
    property var messageContextMenu
    property bool isInPinnedPopup: false
    property bool activityCenterMsg
    property bool placeholderMsg
    property string fromAuthor
    property bool editBtnActive: false
    property bool pinButtonActive: false
    property bool deleteButtonActive: false
    property bool pinnedMessage: false
    property bool canPin: false
    signal replyClicked(string messageId, string author)
    signal hoverChanged(bool hovered)
    signal setMessageActive(string messageId, bool active)
    signal clickMessage(bool isProfileClick, bool isSticker, bool isImage, var image, bool isEmoji, bool hideEmojiPicker)

    visible: !buttonsContainer.isChatBlocked &&
             !buttonsContainer.placeholderMsg && !buttonsContainer.activityCenterMsg &&
             (buttonsContainer.parentIsHovered || isMessageActive)
             && contentType !== Constants.messageContentType.transactionType
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

        Loader {
            active: !buttonsContainer.isInPinnedPopup
            sourceComponent: StatusFlatRoundButton {
                id: emojiBtn
                width: 32
                height: 32
                icon.name: "reaction-b"
                type: StatusFlatRoundButton.Type.Tertiary
                tooltip.text: qsTr("Add reaction")
                onClicked: {
                    setMessageActive(messageId, true)
                    // Set parent, X & Y positions for the messageContextMenu
                    buttonsContainer.messageContextMenu.parent = buttonsContainer
                    buttonsContainer.messageContextMenu.setXPosition = function() { return (-Math.abs(buttonsContainer.width - buttonsContainer.messageContextMenu.emojiContainer.width))}
                    buttonsContainer.messageContextMenu.setYPosition = function() { return (-buttonsContainer.messageContextMenu.height - 4)}
                    buttonsContainer.clickMessage(false, false, false, null, true, false)
                }
                onHoveredChanged: buttonsContainer.hoverChanged(this.hovered)
            }
        }

        Loader {
            active: !buttonsContainer.isInPinnedPopup
            sourceComponent: StatusFlatRoundButton {
                id: replyBtn
                width: 32
                height: 32
                icon.name: "reply"
                type: StatusFlatRoundButton.Type.Tertiary
                tooltip.text: qsTr("Reply")
                onClicked: {
                    buttonsContainer.replyClicked(messageId, fromAuthor);
                    if (messageContextMenu.closeParentPopup) {
                        messageContextMenu.closeParentPopup()
                    }
                }
                onHoveredChanged: buttonsContainer.hoverChanged(this.hovered)
            }
        }

        Loader {
            active: buttonsContainer.editBtnActive && !buttonsContainer.isInPinnedPopup
            sourceComponent: StatusFlatRoundButton {
                id: editButton
                width: 32
                height: 32
                icon.source: Style.svg("edit-message")
                type: StatusFlatRoundButton.Type.Tertiary
                tooltip.text: qsTr("Edit")
                onClicked: messageStore.setEditModeOn(messageId)
                onHoveredChanged: buttonsContainer.hoverChanged(editButton.hovered)
            }
        }

        Loader {
            active: buttonsContainer.pinButtonActive
            sourceComponent: StatusFlatRoundButton {
                id: pinButton
                width: 32
                height: 32
                icon.name: buttonsContainer.pinnedMessage ? "unpin" : "pin"
                type: StatusFlatRoundButton.Type.Tertiary
                tooltip.text: buttonsContainer.pinnedMessage ? qsTr("Unpin") : qsTr("Pin")
                onHoveredChanged: buttonsContainer.hoverChanged(pinButton.hovered)
                onClicked: {
                    if (buttonsContainer.pinnedMessage) {
                        messageStore.unpinMessage(messageId)
                        return;
                    }

                    if (buttonsContainer.canPin) {
                        messageStore.pinMessage(messageId)
                        return;
                    }

                    if (!chatContentModule) {
                        console.warn("error on open pinned messages limit reached from message context menu - chat content module is not set")
                        return;
                    }

                    Global.openPopup(pinnedMessagesPopupComponent, {
                                         store: rootStore,
                                         messageStore: messageStore,
                                         pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                                         messageToPin: buttonsContainer.messageId
                                     });
                }
            }
        }

        Loader {
            active: buttonsContainer.deleteButtonActive && !buttonsContainer.isInPinnedPopup
            sourceComponent: StatusFlatRoundButton {
                id: deleteButton
                width: 32
                height: 32
                type: StatusFlatRoundButton.Type.Tertiary
                icon.name: "delete"
                tooltip.text: qsTr("Delete")
                onHoveredChanged: buttonsContainer.hoverChanged(deleteButton.hovered)
                onClicked: {
                    if (!localAccountSensitiveSettings.showDeleteMessageWarning) {
                        messageStore.deleteMessage(messageId)
                    }
                    else {
                        Global.openPopup(deleteMessageConfirmationDialogComponent)
                    }
                }
            }
        }

        Component {
            id: deleteMessageConfirmationDialogComponent

            ConfirmationDialog {
                header.title: qsTr("Confirm deleting this message")
                confirmationText: qsTr("Are you sure you want to delete this message? Be aware that other clients are not guaranteed to delete the message as well.")
                height: 260
                checkbox.visible: true
                executeConfirm: function () {
                    if (checkbox.checked) {
                        localAccountSensitiveSettings.showDeleteMessageWarning = false
                    }

                    close()
                    messageStore.deleteMessage(messageId)
                }
                onClosed: {
                    destroy()
                }
            }
        }
    }
}
