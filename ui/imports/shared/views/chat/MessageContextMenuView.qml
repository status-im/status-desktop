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

    property var store
    // Important:
    // We're here in case of ChatSection
    // This module is set from `ChatLayout` (each `ChatLayout` has its own chatSectionModule)
    property var chatSectionModule
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
        const nbPinnedMessages = root.store.chatsModelInst.messageView.pinnedMessagesList.count
        return nbPinnedMessages < Constants.maxNumberOfPins
    }

    onHeightChanged: {
        root.y = setYPosition()
    }

    onWidthChanged: {
        root.x = setXPosition()
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
        const numLinkUrls = root.linkUrls.split(" ").length
        copyLinkMenu.enabled = numLinkUrls > 1
        copyLinkAction.enabled = !!root.linkUrls && numLinkUrls === 1 && !emojiOnly && !root.isProfile
        */
        popup()
    }

    function openProfileClicked() {
        openProfilePopup(userName, fromAuthor, identicon, "", nickname);
    }

    Item {
        id: emojiContainer
        width: emojiRow.width
        height: visible ? emojiRow.height : 0
        visible: !hideEmojiPicker && (root.emojiOnly || !root.isProfile)
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
                        chatsModel.toggleReaction(SelectedMessage.messageId, emojiId)
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
            image.source: identicon
            image.isIdenticon: true
        }

        StyledText {
            id: username
            text: Utils.removeStatusEns(isCurrentUser ? root.store.profileModelInst.ens.preferredUsername || userName : userName)
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
                root.openProfileClicked()
                root.close()
            }
        }
    }

    Separator {
        anchors.bottom: viewProfileAction.top
        visible: !root.emojiOnly && !root.hideEmojiPicker
    }

    /*  // copy link feature not ready yet
    StatusMenuItem {
        id: copyLinkAction
        //% "Copy link"
        text: qsTrId("copy-link")
        onTriggered: {
            root.store.chatsModelInst.copyToClipboard(linkUrls.split(" ")[0])
            root.close()
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
            model: root.linkUrls.split(" ")
            delegate: MenuItem {
                id: popupMenuItem
                text: modelData
                onTriggered: {
                    root.store.chatsModelInst.copyToClipboard(modelData)
                    root.close()
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
            root.store.chatsModelInst.copyImageToClipboard(imageSource ? imageSource : "")
            root.close()
        }
        icon.name: "copy"
        enabled: isRightClickOnImage
    }

    StatusMenuItem {
        id: downloadImageAction
        text: qsTr("Download image")
        onTriggered: {
            fileDialog.open()
            root.close()
        }
        icon.name: "download"
        enabled: isRightClickOnImage
    }

    StatusMenuItem {
        id: viewProfileAction
        //% "View Profile"
        text: qsTrId("view-profile")
        onTriggered: {
            root.openProfileClicked()
            root.close()
        }
        icon.name: "profile"
        enabled: isProfile
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
                Global.changeAppSectionBySectionType(Constants.appSection.chat)
                chatSectionModule.createOneToOneChat(fromAuthor, "")
            } else {
                showReplyArea()
            }
            root.close()
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
        id: copyMessageIdAction
        text: qsTr("Copy Message Id")
        icon.name: "chat"
        enabled: store.isDebugEnabled
        onTriggered: {
            root.store.chatsModelInst.copyToClipboard(SelectedMessage.messageId)
            close()
        }
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
                root.store.chatsModelInst.messageView.unPinMessage(messageId, root.store.chatsModelInst.channelView.activeChannel.id)
                return
            }

            if (!canPin) {
                // Open pin modal so that the user can unpin one
                Global.openPopup(pinnedMessagesPopupComponent, {messageToPin: messageId})
                return
            }

            root.store.chatsModelInst.messageView.pinMessage(messageId, root.store.chatsModelInst.channelView.activeChannel.id)
            root.close()
        }
        icon.name: "pin"
        enabled: {
            if(isProfile || emojiOnly || isRightClickOnImage)
                return false

            switch (root.store.chatsModelInst.channelView.activeChannel.chatType) {
            case Constants.chatType.publicChat: return false
            case Constants.chatType.profile: return false
            case Constants.chatType.oneToOne: return true
            case Constants.chatType.privateGroupChat: return root.store.chatsModelInst.channelView.activeChannel.isAdmin(userProfile.pubKey)
            case Constants.chatType.communityChat: return root.store.chatsModelInst.communities.activeCommunity.admin
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
                 (contentType === Constants.messageContentType.messageType ||
                  contentType === Constants.messageContentType.stickerType ||
                  contentType === Constants.messageContentType.emojiType ||
                  contentType === Constants.messageContentType.imageType ||
                  contentType === Constants.messageContentType.audioType)
        //% "Delete message"
        text: qsTrId("delete-message")
        onTriggered: {
            if (!localAccountSensitiveSettings.showDeleteMessageWarning) {
                return root.store.chatsModelInst.messageView.deleteMessage(messageId)
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
                                                       root.store.chatsModelInst.messageView.deleteMessage(messageId)
                                                   }
                                               })
        }
        icon.name: "delete"
        type: StatusMenuItem.Type.Danger
    }

    StatusMenuItem {
        enabled: root.pinnedPopup
        text: qsTr("Jump to")
        onTriggered: {
            positionAtMessage(root.messageId)
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
            root.store.chatsModelInst.downloadImage(imageSource ? imageSource : "", fileDialog.fileUrls)
            fileDialog.close()
        }
        onRejected: {
            fileDialog.close()
        }
    }
}
