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
import shared.controls.chat.menuItems 1.0

StatusMenu {
    id: root

    property var store
    property var reactionModel
    property alias emojiContainer: emojiContainer

    property string myPublicKey: ""
    property bool amIChatAdmin: false

    property string selectedUserPublicKey: ""
    property string selectedUserDisplayName: ""
    property string selectedUserIcon: ""

    property int chatType: Constants.chatType.publicChat
    property string messageId: ""
    property string messageSenderId: ""
    property int messageContentType: Constants.messageContentType.unknownContentType
    property string imageSource: ""

    property bool isProfile: false
    property bool isRightClickOnImage: false
    property bool pinnedPopup: false
    property bool pinMessageAllowedForMembers: false
    property bool isDebugEnabled: false
    property bool isEmoji: false
    property bool isSticker: false
    property bool hideEmojiPicker: true
    property bool pinnedMessage: false
    property bool canPin: false

    readonly property bool isMyMessage: {
        return root.messageSenderId !== "" && root.messageSenderId === root.myPublicKey;
    }
    readonly property bool isMe: {
        return root.selectedUserPublicKey === root.store.contactsStore.myPublicKey;
    }
    readonly property var contactDetails: {
        if (root.selectedUserPublicKey === "" || isMe) {
            return {}
        }
        return Utils.getContactDetailsAsJson(root.selectedUserPublicKey);
    }
    readonly property bool isContact: {
        return root.selectedUserPublicKey !== "" && !!contactDetails.isContact
    }
    readonly property bool isBlockedContact: (!!contactDetails && contactDetails.isBlocked) || false

    readonly property int outgoingVerificationStatus: {
        if (root.selectedUserPublicKey === "" || root.isMe || !root.isContact) {
            return 0
        }
        return contactDetails.verificationStatus
    }
    readonly property int incomingVerificationStatus: {
        if (root.selectedUserPublicKey === "" || root.isMe || !root.isContact) {
            return 0
        }
        return contactDetails.incomingVerificationStatus
    }
    readonly property bool hasPendingContactRequest: {
        return !root.isMe && root.selectedUserPublicKey !== "" &&
            root.store.contactsStore.hasPendingContactRequest(root.selectedUserPublicKey);
    }
    readonly property bool hasReceivedVerificationRequestFrom: {
        if (!root.selectedUserPublicKey || root.isMe || !root.isContact) {
            return false
        }
        return root.store.contactsStore.hasReceivedVerificationRequestFrom(root.selectedUserPublicKey)
    }
    readonly property bool isVerificationRequestSent: {
        if (!root.selectedUserPublicKey || root.isMe || !root.isContact) {
            return false
        }
        return root.outgoingVerificationStatus !== Constants.verificationStatus.unverified &&
                root.outgoingVerificationStatus !== Constants.verificationStatus.verified &&
                root.outgoingVerificationStatus !== Constants.verificationStatus.trusted
    }
    readonly property bool isTrusted: {
        if (!root.selectedUserPublicKey || root.isMe || !root.isContact) {
            return false
        }
        return root.outgoingVerificationStatus === Constants.verificationStatus.trusted ||
                root.incomingVerificationStatus === Constants.verificationStatus.trusted
    }

    readonly property bool userTrustIsUnknown: contactDetails && contactDetails.trustStatus === Constants.trustStatus.unknown
    readonly property bool userIsUntrustworthy: contactDetails && contactDetails.trustStatus === Constants.trustStatus.untrustworthy

    property var emojiReactionsReactedByUser: []

    signal openProfileClicked(string publicKey)
    signal pinMessage(string messageId)
    signal unpinMessage(string messageId)
    signal pinnedMessagesLimitReached(string messageId)
    signal jumpToMessage(string messageId)
    signal shouldCloseParentPopup()
    signal createOneToOneChat(string communityId, string chatId, string ensName)
    signal showReplyArea()
    signal toggleReaction(string messageId, int emojiId)
    signal deleteMessage(string messageId)
    signal editClicked(string messageId)

    function show(userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam, emojiReactionsModel) {
        let newEmojiReactions = []
        if (!!emojiReactionsModel) {
            emojiReactionsModel.forEach(function (emojiReaction) {
                newEmojiReactions[emojiReaction.emojiId] = emojiReaction.currentUserReacted
            })
        }
        root.emojiReactionsReactedByUser = newEmojiReactions;

        /* // copy link feature not ready yet
        const numLinkUrls = root.linkUrls.split(" ").length
        copyLinkMenu.enabled = numLinkUrls > 1
        copyLinkAction.enabled = !!root.linkUrls && numLinkUrls === 1 && !isEmoji && !root.isProfile
        */
        popup()
    }

    onClosed: {
        // Reset selectedUserPublicKey so that associated properties get recalculated on re-open
        selectedUserPublicKey = ""
    }

    width: Math.max(emojiContainer.visible ? emojiContainer.width : 0,
                    (root.isRightClickOnImage && !root.pinnedPopup) ? 176 : 230)

    Item {
        id: emojiContainer
        width: emojiRow.width
        height: visible ? emojiRow.height : 0
        visible: !root.hideEmojiPicker && (root.isEmoji || !root.isProfile) && !root.pinnedPopup
        Row {
            id: emojiRow
            spacing: Style.current.halfPadding
            leftPadding: Style.current.halfPadding
            rightPadding: Style.current.halfPadding
            bottomPadding: root.isEmoji ? 0 : Style.current.padding

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

    ProfileHeader {
        width: parent.width
        visible: root.isProfile

        displayNameVisible: false
        displayNamePlusIconsVisible: true
        editButtonVisible: false
        displayName: root.selectedUserDisplayName
        pubkey: root.selectedUserPublicKey
        icon: root.selectedUserIcon
        trustStatus: contactDetails && contactDetails.trustStatus ? contactDetails.trustStatus
                                                                  : Constants.trustStatus.unknown
        isContact: root.isContact
        isCurrentUser: root.isMe
        userIsEnsVerified: (!!contactDetails && contactDetails.ensVerified) || false
    }

    Item {
        visible: root.isProfile
        height: visible ? root.topPadding : 0
    }

    Separator {
        anchors.bottom: viewProfileAction.top
        visible: !root.isEmoji && !root.hideEmojiPicker && !pinnedPopup
    }

    StatusAction {
        id: copyImageAction
        text: qsTr("Copy image")
        onTriggered: {
            if (root.imageSource) {
                root.store.copyImageToClipboardByUrl(root.imageSource)
            }
            root.close()
        }
        icon.name: "copy"
        enabled: root.isRightClickOnImage && !root.pinnedPopup
    }

    StatusAction {
        id: downloadImageAction
        text: qsTr("Download image")
        onTriggered: {
            fileDialog.open()
            root.close()
        }
        icon.name: "download"
        enabled: root.isRightClickOnImage && !root.pinnedPopup
    }

    ViewProfileMenuItem {
        id: viewProfileAction
        enabled: root.isProfile && !root.pinnedPopup
        onTriggered: {
            root.openProfileClicked(root.selectedUserPublicKey)
            root.close()
        }
    }

    SendMessageMenuItem {
        id: sendMessageMenuItem
        enabled: root.isProfile && root.isContact && !root.isBlockedContact
        onTriggered: {
            root.createOneToOneChat("", root.selectedUserPublicKey, "")
            root.close()
        }
    }

    SendContactRequestMenuItem {
        enabled: root.isProfile && !root.isMe && !root.isContact
                                && !root.isBlockedContact && !root.hasPendingContactRequest
        onTriggered: {
            Global.openContactRequestPopup(root.selectedUserPublicKey, null)
            root.close()
        }
    }

    StatusAction {
        text: qsTr("Verify Identity")
        icon.name: "checkmark-circle"
        enabled: root.isProfile && !root.isMe && root.isContact
                                && !root.isBlockedContact
                                && root.outgoingVerificationStatus === Constants.verificationStatus.unverified
                                && !root.hasReceivedVerificationRequestFrom
        onTriggered: {
            Global.openSendIDRequestPopup(root.selectedUserPublicKey, null)
            root.close()
        }
    }

    StatusAction {
         text: isVerificationRequestSent ||
            root.incomingVerificationStatus === Constants.verificationStatus.verified ?
            qsTr("ID Request Pending....") :
            qsTr("Respond to ID Request...")
        icon.name: "checkmark-circle"
        enabled: root.isProfile && !root.isMe && root.isContact
                                && !root.isBlockedContact && !root.isTrusted
                                && (root.hasReceivedVerificationRequestFrom
                                    || root.isVerificationRequestSent)
        onTriggered: {
            if (hasReceivedVerificationRequestFrom) {
                Global.openIncomingIDRequestPopup(root.selectedUserPublicKey, null)
            } else if (root.isVerificationRequestSent) {
                Global.openOutgoingIDRequestPopup(root.selectedUserPublicKey, null)
            }

            root.close()
        }
    }

    StatusAction {
        text: qsTr("Rename")
        icon.name: "edit_pencil"
        enabled: root.isProfile && !root.isMe
        onTriggered: {
            Global.openNicknamePopupRequested(root.selectedUserPublicKey, contactDetails.localNickname,
                                              "%1 (%2)".arg(root.selectedUserDisplayName).arg(Utils.getElidedCompressedPk(root.selectedUserPublicKey)))
            root.close()
        }
    }

    StatusAction {
        text: qsTr("Unblock User")
        icon.name: "remove-circle"
        enabled: root.isProfile && !root.isMe && root.isBlockedContact
        onTriggered: Global.unblockContactRequested(root.selectedUserPublicKey, root.selectedUserDisplayName)
    }

    StatusMenuSeparator {
        visible: blockMenuItem.enabled || markUntrustworthyMenuItem.enabled || removeUntrustworthyMarkMenuItem.enabled
    }

    StatusAction {
        id: markUntrustworthyMenuItem
        text: qsTr("Mark as Untrustworthy")
        icon.name: "warning"
        type: StatusAction.Type.Danger
        enabled: root.isProfile && !root.isMe && root.userTrustIsUnknown
        onTriggered: root.store.contactsStore.markUntrustworthy(root.selectedUserPublicKey)
    }

    StatusAction {
        id: removeUntrustworthyMarkMenuItem
        text: qsTr("Remove Untrustworthy Mark")
        icon.name: "warning"
        enabled: root.isProfile && !root.isMe && root.userIsUntrustworthy
        onTriggered: root.store.contactsStore.removeTrustStatus(root.selectedUserPublicKey)
    }

    StatusAction {
        id: blockMenuItem
        text: qsTr("Block User")
        icon.name: "cancel"
        type: StatusAction.Type.Danger
        enabled: root.isProfile && !root.isMe && !root.isBlockedContact
        onTriggered: Global.blockContactRequested(root.selectedUserPublicKey, root.selectedUserDisplayName)
    }

    StatusAction {
        id: replyToMenuItem
        text: qsTr("Reply to")
        icon.name: "chat"
        onTriggered: {
            root.showReplyArea()
            root.close()
        }
        enabled: (!root.hideEmojiPicker &&
                  !root.isEmoji &&
                  !root.isProfile &&
                  !root.pinnedPopup &&
                  !root.isRightClickOnImage)
    }

    StatusAction {
        id: editMessageAction
        text: qsTr("Edit message")
        onTriggered: {
            editClicked(messageId)
        }
        icon.name: "edit"
        enabled: root.isMyMessage &&
                 !root.hideEmojiPicker &&
                 !root.isEmoji &&
                 !root.isSticker &&
                 !root.isProfile &&
                 !root.pinnedPopup &&
                 !root.isRightClickOnImage
    }

    StatusAction {
        id: copyMessageIdAction
        text: qsTr("Copy Message Id")
        icon.name: "chat"
        enabled: root.isDebugEnabled && !pinnedPopup
        onTriggered: {
            root.store.copyToClipboard(SelectedMessage.messageId)
            close()
        }
    }

    StatusAction {
        id: pinAction
        text: {
            if (root.pinnedMessage) {
                return qsTr("Unpin")
            }
            return qsTr("Pin")

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
            if(root.isProfile || root.isEmoji || root.isRightClickOnImage)
                return false

            if (root.pinnedPopup)
                return true

            switch (root.chatType) {
            case Constants.chatType.publicChat:
                return false
            case Constants.chatType.profile:
                return false
            case Constants.chatType.oneToOne:
                return true
            case Constants.chatType.privateGroupChat:
                return root.amIChatAdmin
            case Constants.chatType.communityChat:
                return root.amIChatAdmin || root.pinMessageAllowedForMembers
            default:
                return false
            }
        }
    }

    StatusMenuSeparator {
        visible: deleteMessageAction.enabled &&
                 (viewProfileAction.enabled ||
                  sendMessageMenuItem.enabled ||
                  replyToMenuItem.enabled ||
                  editMessageAction.enabled ||
                  pinAction.enabled)
    }

    StatusAction {
        id: deleteMessageAction
        enabled: root.isMyMessage &&
                 !root.isProfile &&
                 !root.isEmoji &&
                 !root.pinnedPopup &&
                 !root.isRightClickOnImage &&
                 (root.messageContentType === Constants.messageContentType.messageType ||
                  root.messageContentType === Constants.messageContentType.stickerType ||
                  root.messageContentType === Constants.messageContentType.emojiType ||
                  root.messageContentType === Constants.messageContentType.imageType ||
                  root.messageContentType === Constants.messageContentType.audioType)
        text: qsTr("Delete message")
        onTriggered: {
            if (!localAccountSensitiveSettings.showDeleteMessageWarning) {
                deleteMessage(messageId)
            }
            else {
                Global.openPopup(deleteMessageConfirmationDialogComponent)
            }
        }
        icon.name: "delete"
        type: StatusAction.Type.Danger
    }

    StatusAction {
        id: jumpToAction
        enabled: root.pinnedPopup && !root.isProfile
        text: qsTr("Jump to")
        onTriggered: {
            root.jumpToMessage(root.messageId)
            root.close()
            root.shouldCloseParentPopup()
        }
        icon.name: "arrow-up"
    }

    FileDialog {
        id: fileDialog
        title: qsTr("Please choose a directory")
        selectFolder: true
        modality: Qt.NonModal
        onAccepted: {
            if (root.imageSource) {
                root.store.downloadImageByUrl(root.imageSource, fileDialog.fileUrls)
            }
            fileDialog.close()
        }
        onRejected: {
            fileDialog.close()
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
                root.deleteMessage(messageId)
            }
            onClosed: {
                destroy()
            }
        }
    }
}
