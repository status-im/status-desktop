import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQuick.Dialogs 1.0

import StatusQ.Popups 0.1


import utils 1.0
import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/panels"
import "../../../../shared/status"
import "../controls"

StatusPopupMenu {
    id: messageContextMenu
    width: emojiContainer.visible ? emojiContainer.width : 176

    property string messageId
    property int contentType
    property bool isProfile: false
    property bool isSticker: false
    property bool emojiOnly: false
    property bool hideEmojiPicker: false
    property bool pinnedMessage: false
    property bool pinnedPopup: false
    property bool isText: false
    property bool isCurrentUser: false
    property bool isRightClickOnImage: false
    property string linkUrls: ""
    property alias emojiContainer: emojiContainer
    property var identicon: ""
    property var userName: ""
    property string nickname: ""
    property var fromAuthor: ""
    property var text: ""
    property var emojiReactionsReactedByUser: []
    property var onClickEdit: function(){}
    property var reactionModel
    property string imageSource: ""
    property var setXPosition: function() {return 0}
    property var setYPosition: function() {return 0}
    property bool canPin: {
        const nbPinnedMessages = chatsModel.messageView.pinnedMessagesList.count
        return nbPinnedMessages < Constants.maxNumberOfPins
    }

    onHeightChanged: {
        messageContextMenu.y = setYPosition()
    }

    onWidthChanged: {
        messageContextMenu.x = setXPosition()
    }

    signal shouldCloseParentPopup

    function show(userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam, emojiReactionsModel) {
        userName = userNameParam || ""
        nickname = nicknameParam || ""
        fromAuthor = fromAuthorParam || ""
        identicon = identiconParam || ""
        text = textParam || ""
        let newEmojiReactions = []
        if (!!emojiReactionsModel) {
            emojiReactionsModel.forEach(function (emojiReaction) {
                newEmojiReactions[emojiReaction.emojiId] = emojiReaction.currentUserReacted
            })
        }
        emojiReactionsReactedByUser = newEmojiReactions;

        /* // copy link feature not ready yet
        const numLinkUrls = messageContextMenu.linkUrls.split(" ").length
        copyLinkMenu.enabled = numLinkUrls > 1
        copyLinkAction.enabled = !!messageContextMenu.linkUrls && numLinkUrls === 1 && !emojiOnly && !messageContextMenu.isProfile
        */
        popup()
    }

    Item {
        id: emojiContainer
        width: emojiRow.width
        height: visible ? emojiRow.height : 0
        visible: !hideEmojiPicker && (messageContextMenu.emojiOnly || !messageContextMenu.isProfile)
        Row {
            id: emojiRow
            spacing: Style.current.halfPadding
            leftPadding: Style.current.halfPadding
            rightPadding: Style.current.halfPadding
            bottomPadding: messageContextMenu.emojiOnly ? 0 : Style.current.padding

            Repeater {
                model: messageContextMenu.reactionModel
                delegate: EmojiReaction {
                    source: Style.svg(filename)
                    emojiId: model.emojiId
                    reactedByUser: !!messageContextMenu.emojiReactionsReactedByUser[model.emojiId]
                    onCloseModal: {
                        chatsModel.toggleReaction(SelectedMessage.messageId, emojiId)
                        messageContextMenu.close()
                    }
                }
            }
        }
    }

    Item {
        id: profileHeader
        visible: messageContextMenu.isProfile
        width: parent.width
        height: visible ? profileImage.height + username.height + Style.current.padding : 0
        Rectangle {
            anchors.fill: parent
            visible: mouseArea.containsMouse
            color: Style.current.backgroundHover
        }
        StatusImageIdenticon {
            id: profileImage
            source: identicon
            anchors.top: parent.top
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            id: username
            text: Utils.removeStatusEns(isCurrentUser ? profileModel.ens.preferredUsername || userName : userName)
            elide: Text.ElideRight
            maximumLineCount: 3
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            anchors.top: profileImage.bottom
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            font.weight: Font.Medium
            font.pixelSize: 15
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                openProfilePopup(userName, fromAuthor, identicon);
                messageContextMenu.close()
            }
        }
    }

    Separator {
        anchors.bottom: viewProfileAction.top
        visible: !messageContextMenu.emojiOnly && !messageContextMenu.hideEmojiPicker
    }

    /*  // copy link feature not ready yet
    StatusMenuItem {
        id: copyLinkAction
        //% "Copy link"
        text: qsTrId("copy-link")
        onTriggered: {
            chatsModel.copyToClipboard(linkUrls.split(" ")[0])
            messageContextMenu.close()
        }
        icon.name: "link"
        enabled: false
    }

    // TODO: replace with StatusPopupMenu
    PopupMenu {
        id: copyLinkMenu
        //% "Copy link"
        title: qsTrId("copy-link")

        Repeater {
            id: linksRepeater
            model: messageContextMenu.linkUrls.split(" ")
            delegate: MenuItem {
                id: popupMenuItem
                text: modelData
                onTriggered: {
                    chatsModel.copyToClipboard(modelData)
                    messageContextMenu.close()
                }
                contentItem: StyledText {
                    text: popupMenuItem.text
                    font: popupMenuItem.font
                    color: Style.current.textColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                background: Rectangle {
                    implicitWidth: 220
                    implicitHeight: 34
                    color: popupMenuItem.highlighted ? Style.current.backgroundHover: Style.current.transparent
                }
            }
        }
    }
    */

    StatusMenuItem {
        id: copyImageAction
        text: qsTr("Copy image")
        onTriggered: {
            chatsModel.copyImageToClipboard(imageSource ? imageSource : "")
            messageContextMenu.close()
        }
        icon.name: "copy"
        enabled: isRightClickOnImage
    }

    StatusMenuItem {
        id: downloadImageAction
        text: qsTr("Download image")
        onTriggered: {
            fileDialog.open()
            messageContextMenu.close()
        }
        icon.name: "download"
        enabled: isRightClickOnImage
    }

    StatusMenuItem {
        id: viewProfileAction
        //% "View Profile"
        text: qsTrId("view-profile")
        onTriggered: {
            openProfilePopup(userName, fromAuthor, identicon, "", nickname);
            messageContextMenu.close()
        }
        icon.name: "profile"
        enabled: isProfile
    }

    StatusMenuItem {
        id: sendMessageOrReplyTo
        text: messageContextMenu.isProfile ?
                  //% "Send message"
                  qsTrId("send-message") :
                  //% "Reply to"
                  qsTrId("reply-to")
        onTriggered: {
            if (messageContextMenu.isProfile) {
                appMain.changeAppSection(Constants.chat)
                chatsModel.channelView.joinPrivateChat(fromAuthor, "")
            } else {
                showReplyArea()
            }
            messageContextMenu.close()
        }
        icon.name: "chat"
        enabled: isProfile || (!hideEmojiPicker && !emojiOnly && !isProfile && !isRightClickOnImage)
    }

    StatusMenuItem {
        id: editMessageAction
        //% "Edit message"
        text: qsTrId("edit-message")
        onTriggered: {
            onClickEdit();
        }
        icon.name: "edit"
        enabled: isCurrentUser && !hideEmojiPicker && !emojiOnly && !isProfile && !isRightClickOnImage
    }

    StatusMenuItem {
        id: pinAction
        text: {
            if (pinnedMessage) {
                //% "Unpin"
                return qsTrId("unpin")
            }
            //% "Pin"
            return qsTrId("pin")

        }
        onTriggered: {
            if (pinnedMessage) {
                chatsModel.messageView.unPinMessage(messageId, chatsModel.channelView.activeChannel.id)
                return
            }

            if (!canPin) {
                // Open pin modal so that the user can unpin one
                openPopup(pinnedMessagesPopupComponent, {messageToPin: messageId})
                return
            }

            chatsModel.messageView.pinMessage(messageId, chatsModel.channelView.activeChannel.id)
            messageContextMenu.close()
        }
        icon.name: "pin"
        enabled: {
            if(isProfile || emojiOnly || isRightClickOnImage)
                return false

            switch (chatsModel.channelView.activeChannel.chatType) {
            case Constants.chatTypePublic: return false
            case Constants.chatTypeStatusUpdate: return false
            case Constants.chatTypeOneToOne: return true
            case Constants.chatTypePrivateGroupChat: return chatsModel.channelView.activeChannel.isAdmin(profileModel.profile.pubKey)
            case Constants.chatTypeCommunity: return chatsModel.communities.activeCommunity.admin
            }

            return false
        }
    }

    StatusMenuSeparator {
        visible: deleteMessageAction.enabled && (viewProfileAction.visible
                || sendMessageOrReplyTo.visible || editMessageAction.visible || pinAction.visible)
    }

    StatusMenuItem {
        id: deleteMessageAction
        enabled: isCurrentUser && !isProfile && !emojiOnly && !pinnedPopup && !isRightClickOnImage &&
                 (contentType === Constants.messageType ||
                  contentType === Constants.stickerType ||
                  contentType === Constants.emojiType ||
                  contentType === Constants.imageType ||
                  contentType === Constants.audioType)
        //% "Delete message"
        text: qsTrId("delete-message")
        onTriggered: {
            if (!appSettings.showDeleteMessageWarning) {
                return chatsModel.messageView.deleteMessage(messageId)
            }

            let confirmationDialog = openPopup(genericConfirmationDialog, {
                                                   //% "Confirm deleting this message"
                                                   title: qsTrId("confirm-deleting-this-message"),
                                                   //% "Are you sure you want to delete this message? Be aware that other clients are not guaranteed to delete the message as well."
                                                   confirmationText: qsTrId("are-you-sure-you-want-to-delete-this-message--be-aware-that-other-clients-are-not-guaranteed-to-delete-the-message-as-well-"),
                                                   height: 260,
                                                   "checkbox.visible": true,
                                                   executeConfirm: function () {
                                                       if (confirmationDialog.checkbox.checked) {
                                                           appSettings.showDeleteMessageWarning = false
                                                       }

                                                       confirmationDialog.close()
                                                       chatsModel.messageView.deleteMessage(messageId)
                                                   }
                                               })
        }
        icon.name: "delete"
        type: StatusMenuItem.Type.Danger
    }

    StatusMenuItem {
        enabled: messageContextMenu.pinnedPopup
        text: qsTr("Jump to")
        onTriggered: {
            positionAtMessage(messageContextMenu.messageId)
            messageContextMenu.close()
            messageContextMenu.shouldCloseParentPopup()
        }
        icon.name: "up"
    }

    FileDialog {
        id: fileDialog
        title: qsTr("Please choose a directory")
        selectFolder: true
        modality: Qt.NonModal
        onAccepted: {
            chatsModel.downloadImage(imageSource ? imageSource : "", fileDialog.fileUrls)
            fileDialog.close()
        }
        onRejected: {
            fileDialog.close()
        }
    }
}
