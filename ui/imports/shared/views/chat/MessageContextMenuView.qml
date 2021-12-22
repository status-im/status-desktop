import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQuick.Dialogs 1.0

import StatusQ.Popups 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls.chat 1.0

StatusPopupMenu {
    id: root
    width: emojiContainer.visible ? emojiContainer.width : 176

    property var reactionModel
    property alias emojiContainer: emojiContainer

    property string myPublicKey: ""
    property bool amIAdmin: false
    property bool isMyMessage: {
        return root.messageSenderId !== "" && root.messageSenderId == root.myPublicKey
    }

    property int chatType: Constants.chatType.publicChat
    property string messageId: ""
    property string messageSenderId: ""
    property int messageContentType: Constants.messageContentType.unknownContentType
    property string selectedUserPublicKey: ""
    property string selectedUserDisplayName: ""
    property string selectedUserIcon: ""
    property bool isSelectedUserIconIdenticon: true
    property string imageSource: ""

    property bool isProfile: false
    property bool isRightClickOnImage: false
    property bool pinnedPopup: false
    property bool isDebugEnabled: false
    property bool emojiOnly: false
    property bool hideEmojiPicker: true
    property bool pinnedMessage: false
    property bool canPin: false

    property var setXPosition: function() {return 0}
    property var setYPosition: function() {return 0}

    signal openProfileClicked(string publicKey, string displayName, string icon) // TODO: optimization, only publicKey is more than enough to be sent from here
    signal pinMessage(string messageId)
    signal unpinMessage(string messageId)
    signal pinnedMessagesLimitReached(string messageId)
    signal jumpToMessage(string messageId)
    signal shouldCloseParentPopup()
    signal createOneToOneChat(string chatId, string ensName)
    signal showReplyArea()
    signal toggleReaction(string messageId, int emojiId)

    onHeightChanged: {
        root.y = setYPosition()
    }

    onWidthChanged: {
        root.x = setXPosition()
    }

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
        const numLinkUrls = root.linkUrls.split(" ").length
        copyLinkMenu.enabled = numLinkUrls > 1
        copyLinkAction.enabled = !!root.linkUrls && numLinkUrls === 1 && !emojiOnly && !root.isProfile
        */
        popup()
    }

    Item {
        id: emojiContainer
        width: emojiRow.width
        height: visible ? emojiRow.height : 0
        visible: !root.hideEmojiPicker && (root.emojiOnly || !root.isProfile)
        Row {
            id: emojiRow
            spacing: Style.current.halfPadding
            leftPadding: Style.current.halfPadding
            rightPadding: Style.current.halfPadding
            bottomPadding: root.emojiOnly ? 0 : Style.current.padding

            Repeater {
                model: root.reactionModel
                delegate: EmojiReaction {
                    source: Style.svg(filename)
                    emojiId: model.emojiId
                    reactedByUser: !!root.emojiReactionsReactedByUser[model.emojiId]
                    onCloseModal: {
                        root.toggleReaction(root.messageId, emojiId)
                        root.close()
                    }
                }
            }
        }
    }

    Item {
        id: profileHeader
        visible: root.isProfile
        width: parent.width
        height: visible ? profileImage.height + username.height + Style.current.padding : 0
        Rectangle {
            anchors.fill: parent
            visible: mouseArea.containsMouse
            color: Style.current.backgroundHover
        }

        StatusSmartIdenticon {
            id: profileImage
            anchors.top: parent.top
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
            image.source: root.selectedUserIcon
            image.isIdenticon: root.isSelectedUserIconIdenticon
        }

        StyledText {
            id: username
            text: selectedUserDisplayName
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
                root.openProfileClicked(root.selectedUserPublicKey, root.selectedUserDisplayName, root.selectedUserIcon)
                root.close()
            }
        }
    }

    Separator {
        anchors.bottom: viewProfileAction.top
        visible: !root.emojiOnly && !root.hideEmojiPicker
    }

    StatusMenuItem {
        id: copyImageAction
        text: qsTr("Copy image")
        onTriggered: {
            // Not Refactored Yet - Should be in GlobalUtils
//            root.store.chatsModelInst.copyImageToClipboard(imageSource ? imageSource : "")
            root.close()
        }
        icon.name: "copy"
        enabled: root.isRightClickOnImage
    }

    StatusMenuItem {
        id: downloadImageAction
        text: qsTr("Download image")
        onTriggered: {
            fileDialog.open()
            root.close()
        }
        icon.name: "download"
        enabled: root.isRightClickOnImage
    }

    StatusMenuItem {
        id: viewProfileAction
        //% "View Profile"
        text: qsTrId("view-profile")
        onTriggered: {
            root.openProfileClicked(root.selectedUserPublicKey, root.selectedUserDisplayName, root.selectedUserIcon)
            root.close()
        }
        icon.name: "profile"
        enabled: root.isProfile
    }

    StatusMenuItem {
        id: sendMessageOrReplyTo
        text: root.isProfile ?
                  //% "Send message"
                  qsTrId("send-message") :
                  //% "Reply to"
                  qsTrId("reply-to")
        onTriggered: {
            if (root.isProfile) {
                root.createOneToOneChat(root.selectedUserPublicKey, "")
            } else {
                root.showReplyArea()
            }
            root.close()
        }
        icon.name: "chat"
        enabled: root.isProfile ||
                 (!root.hideEmojiPicker &&
                  !root.emojiOnly &&
                  !root.isProfile &&
                  !root.isRightClickOnImage)
    }

    StatusMenuItem {
        id: editMessageAction
        //% "Edit message"
        text: qsTrId("edit-message")
        onTriggered: {
            onClickEdit();
        }
        icon.name: "edit"
        enabled: root.isMyMessage &&
                 !root.hideEmojiPicker &&
                 !root.emojiOnly &&
                 !root.isProfile &&
                 !root.isRightClickOnImage
    }

    StatusMenuItem {
        id: copyMessageIdAction
        text: qsTr("Copy Message Id")
        icon.name: "chat"
        enabled: root.isDebugEnabled
        onTriggered: {
            // Not Refactored Yet - Should be in GlobalUtils
//            root.store.chatsModelInst.copyToClipboard(SelectedMessage.messageId)
            close()
        }
    }

    StatusMenuItem {
        id: pinAction
        text: {
            if (root.pinnedMessage) {
                //% "Unpin"
                return qsTrId("unpin")
            }
            //% "Pin"
            return qsTrId("pin")

        }
        onTriggered: {
            if (root.pinnedMessage) {
                root.unpinMessage(root.messageId)
                return
            }

            if (!root.canPin) {
                root.pinnedMessagesLimitReached(root.messageId)
                return
            }

            root.pinMessage(root.messageId)
            root.close()
        }
        icon.name: "pin"
        enabled: {
            if(root.isProfile || root.emojiOnly || root.isRightClickOnImage)
                return false

            switch (root.chatType) {
            case Constants.chatType.publicChat:
                return false
            case Constants.chatType.profile:
                return false
            case Constants.chatType.oneToOne:
                return true
            case Constants.chatType.privateGroupChat:
                return root.amIAdmin
            case Constants.chatType.communityChat:
                return root.amIAdmin
            default:
                return false
            }
        }
    }

    StatusMenuSeparator {
        visible: deleteMessageAction.enabled &&
                 (viewProfileAction.visible ||
                  sendMessageOrReplyTo.visible ||
                  editMessageAction.visible ||
                  pinAction.visible)
    }

    StatusMenuItem {
        id: deleteMessageAction
        enabled: root.isMyMessage &&
                 !root.isProfile &&
                 !root.emojiOnly &&
                 !root.pinnedPopup &&
                 !root.isRightClickOnImage &&
                 (root.messageContentType === Constants.messageContentType.messageType ||
                  root.messageContentType === Constants.messageContentType.stickerType ||
                  root.messageContentType === Constants.messageContentType.emojiType ||
                  root.messageContentType === Constants.messageContentType.imageType ||
                  root.messageContentType === Constants.messageContentType.audioType)
        //% "Delete message"
        text: qsTrId("delete-message")
        onTriggered: {
            if (!localAccountSensitiveSettings.showDeleteMessageWarning) {
                // Not Refactored Yet
//                return root.store.chatsModelInst.messageView.deleteMessage(messageId)
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
                                                           localAccountSensitiveSettings.showDeleteMessageWarning = false
                                                       }

                                                       confirmationDialog.close()
                                                       // Not Refactored Yet
//                                                       root.store.chatsModelInst.messageView.deleteMessage(messageId)
                                                   }
                                               })
        }
        icon.name: "delete"
        type: StatusMenuItem.Type.Danger
    }

    StatusMenuItem {
        id: jumpToAction
        enabled: root.pinnedPopup
        text: qsTr("Jump to")
        onTriggered: {
            root.jumpToMessage(root.messageId)
            root.close()
            root.shouldCloseParentPopup()
        }
        icon.name: "up"
    }

    FileDialog {
        id: fileDialog
        title: qsTr("Please choose a directory")
        selectFolder: true
        modality: Qt.NonModal
        onAccepted: {
            // Not Refactored Yet - Should be in GlobalUtils
//            root.store.chatsModelInst.downloadImage(imageSource ? imageSource : "", fileDialog.fileUrls)
            fileDialog.close()
        }
        onRejected: {
            fileDialog.close()
        }
    }
}
