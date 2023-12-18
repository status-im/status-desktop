import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared 1.0
import shared.views 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.views.chat 1.0

import "../controls"
import "../panels"

Item {
    id: root

    property var chatContentModule
    property var rootStore
    property var messageStore
    property var usersStore
    property var contactsStore
    property string channelEmoji

    property var emojiPopup
    property var stickersPopup

    property string chatId: ""
    property bool stickersLoaded: false
    property alias chatLogView: chatLogView
    property bool isContactBlocked: false
    property bool isChatBlocked: false
    property bool isOneToOne: false
    property bool isActiveChannel: false

    signal openStickerPackPopup(string stickerPackId)
    signal showReplyArea(string messageId, string author)
    signal editModeChanged(bool editModeOn)

    QtObject {
        id: d

        readonly property real scrollY: chatLogView.visibleArea.yPosition * chatLogView.contentHeight
        readonly property bool isMostRecentMessageInViewport: chatLogView.visibleArea.yPosition >= 0.999 - chatLogView.visibleArea.heightRatio
        readonly property var chatDetails: chatContentModule && chatContentModule.chatDetails || null
        readonly property bool keepUnread: messageStore.keepUnread

        readonly property var loadMoreMessagesIfScrollBelowThreshold: Backpressure.oneInTimeQueued(root, 100, function() {
            if(scrollY < 1000) messageStore.loadMoreMessages()
        })

        function setKeepUnread(flag: bool) {
            root.messageStore.setKeepUnread(flag)
        }

        function markAllMessagesReadIfMostRecentMessageIsInViewport() {
            if (!isMostRecentMessageInViewport || !chatLogView.visible || keepUnread) {
                return
            }

            if (chatDetails && chatDetails.active && (chatDetails.hasUnreadMessages || chatDetails.highlight) && !messageStore.loading) {
                chatContentModule.markAllMessagesRead()
            }
        }

        function goToMessage(messageIndex) {
            chatLogView.currentIndex = -1
            chatLogView.currentIndex = messageIndex
        }

        onIsMostRecentMessageInViewportChanged: markAllMessagesReadIfMostRecentMessageIsInViewport()
    }

    Connections {
        target: root.messageStore.messageModule

        function onMessageSuccessfullySent() {
            chatLogView.positionViewAtBeginning()
        }

        function onSendingMessageFailed() {
            sendingMsgFailedPopup.open()
        }

        function onScrollToMessage(messageIndex) {
            d.goToMessage(messageIndex)
        }
    }

    Connections {
        target: root.messageStore

        function onMessageSearchOngoingChanged() {
            d.markAllMessagesReadIfMostRecentMessageIsInViewport()
        }

        function onLoadingChanged() {
            d.markAllMessagesReadIfMostRecentMessageIsInViewport()
        }
    }

    Connections {
        target: !!d.chatDetails ? d.chatDetails : null

        function onActiveChanged() {
            d.setKeepUnread(false)
            d.markAllMessagesReadIfMostRecentMessageIsInViewport()
            d.loadMoreMessagesIfScrollBelowThreshold()
        }

        function onHasUnreadMessagesChanged() {
            if (!d.chatDetails.hasUnreadMessages) {
                return
            }

            // HACK: we call `addNewMessagesMarker` later because messages model
            // may not be yet propagated with unread messages when this signal is emitted
            if (chatLogView.visible && !d.isMostRecentMessageInViewport) {
                Qt.callLater(() => messageStore.addNewMessagesMarker())
            }
        }
    }

    Connections {
        target: root.rootStore
        enabled: d.chatDetails && d.chatDetails.active

        function onLoadingHistoryMessagesInProgressChanged() {
            if(!root.rootStore.loadingHistoryMessagesInProgress) {
                d.loadMoreMessagesIfScrollBelowThreshold()
            }
        }
    }

    Item {
        id: loadingMessagesIndicator
        visible: root.rootStore.loadingHistoryMessagesInProgress
        anchors.top: parent.top
        anchors.left: parent.left
        height: visible? 20 : 0
        width: parent.width

        Loader {
            active: root.rootStore.loadingHistoryMessagesInProgress
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: Component {
                LoadingAnimation {
                    width: 18
                    height: 18
                }
            }
        }
    }

    Loader {
        id: loadingMessagesView

        anchors.top: loadingMessagesIndicator.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        active: messageStore.loading
        visible: active
        sourceComponent: MessagesLoadingView {
            anchors.margins: 16
            anchors.fill: parent
        }
    }

    StatusListView {
        id: chatLogView
        visible: !loadingMessagesView.visible
        objectName: "chatLogView"
        anchors.top: loadingMessagesIndicator.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0
        verticalLayoutDirection: ListView.BottomToTop
        cacheBuffer: height > 0 ? height * 2 : 0 // cache 2 screens worth of items

        highlightRangeMode: ListView.ApplyRange
        highlightMoveDuration: 200
        preferredHighlightBegin: 0
        preferredHighlightEnd: chatLogView.height / 2

        Binding on flickDeceleration {
            when: localAppSettings.isCustomMouseScrollingEnabled
            value: localAppSettings.scrollDeceleration
            restoreMode: Binding.RestoreBindingOrValue
        }

        Binding on maximumFlickVelocity {
            when: localAppSettings.isCustomMouseScrollingEnabled
            value: localAppSettings.scrollVelocity
            restoreMode: Binding.RestoreBindingOrValue
        }

        model: messageStore.messagesModel

        onContentYChanged: d.loadMoreMessagesIfScrollBelowThreshold()

        onCountChanged: {
            d.markAllMessagesReadIfMostRecentMessageIsInViewport()

            // after inilial messages are loaded
            // load as much messages as the view requires
            if (!messageStore.loading) {
                d.loadMoreMessagesIfScrollBelowThreshold()
            }
        }

        onVisibleChanged: d.markAllMessagesReadIfMostRecentMessageIsInViewport()

        onCurrentItemChanged: {
            if(currentItem && currentIndex > 0) {
                currentItem.startMessageFoundAnimation()
            }
        }

        ScrollBar.vertical: StatusScrollBar {
            visible: chatLogView.visibleArea.heightRatio < 1
        }

        ChatAnchorButtonsPanel {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding

            mentionsCount: d.chatDetails ? d.chatDetails.notificationCount : 0
            recentMessagesButtonVisible: {
                chatLogView.contentY // trigger binding on contentY change
                return chatLogView.contentHeight - (d.scrollY + chatLogView.height) > 400
            }

            onRecentMessagesButtonClicked: chatLogView.positionViewAtBeginning()
            onMentionsButtonClicked: {
                let id = messageStore.firstUnseenMentionMessageId()
                if (id !== "") {
                    messageStore.jumpToMessage(id)
                    chatContentModule.markMessageRead(id)
                }
            }
        }

        delegate: MessageView {
            id: msgDelegate

            width: ListView.view.width

            objectName: "chatMessageViewDelegate"
            rootStore: root.rootStore
            messageStore: root.messageStore
            usersStore: root.usersStore
            contactsStore: root.contactsStore
            channelEmoji: root.channelEmoji
            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            chatLogView: ListView.view
            chatContentModule: root.chatContentModule

            isChatBlocked: root.isChatBlocked

            chatId: root.chatId
            messageId: model.id
            communityId: model.communityId
            responseToMessageWithId: model.responseToMessageWithId
            senderId: model.senderId
            senderDisplayName: model.senderDisplayName
            senderOptionalName: model.senderOptionalName
            senderIsEnsVerified: model.senderEnsVerified
            senderIcon: model.senderIcon
            senderColorHash: model.senderColorHash
            senderIsAdded: model.senderIsAdded
            senderTrustStatus: model.senderTrustStatus
            amISender: model.amISender
            messageText: model.messageText
            unparsedText: model.unparsedText
            messageImage: model.messageImage
            album: model.albumMessageImages.split(" ")
            albumCount: model.albumImagesCount
            messageTimestamp: model.timestamp
            messageOutgoingStatus: model.outgoingStatus
            resendError: model.resendError
            messageContentType: model.contentType
            pinnedMessage: model.pinned
            messagePinnedBy: model.pinnedBy
            reactionsModel: model.reactions
            emojiReactionsModel: model.emojiReactionsModel
            sticker: model.sticker
            stickerPack: model.stickerPack
            editModeOn: model.editMode
            onEditModeOnChanged: root.editModeChanged(editModeOn)
            isEdited: model.isEdited
            deleted: model.deleted
            deletedBy: model.deletedBy
            deletedByContactDisplayName: model.deletedByContactDisplayName
            deletedByContactIcon: model.deletedByContactIcon
            deletedByContactColorHash: model.deletedByContactColorHash
            linkPreviewModel: model.linkPreviewModel
            links: model.links
            messageAttachments: model.messageAttachments
            transactionParams: model.transactionParameters
            hasMention: model.mentioned
            quotedMessageText: model.quotedMessageParsedText
            quotedMessageFrom: model.quotedMessageFrom
            quotedMessageContentType: model.quotedMessageContentType
            quotedMessageDeleted: model.quotedMessageDeleted
            quotedMessageAuthorDetailsName: model.quotedMessageAuthorName
            quotedMessageAuthorDetailsDisplayName: model.quotedMessageAuthorDisplayName
            quotedMessageAuthorDetailsThumbnailImage: model.quotedMessageAuthorThumbnailImage
            quotedMessageAuthorDetailsEnsVerified: model.quotedMessageAuthorEnsVerified
            quotedMessageAuthorDetailsIsContact: model.quotedMessageAuthorIsContact
            quotedMessageAuthorDetailsColorHash: model.quotedMessageAuthorColorHash
            quotedMessageAlbumMessageImages: model.quotedMessageAlbumMessageImages.split(" ")
            quotedMessageAlbumImagesCount: model.quotedMessageAlbumImagesCount

            gapFrom: model.gapFrom
            gapTo: model.gapTo

             // This is possible since we have all data loaded before we load qml.
             // When we fetch messages to fulfill a gap we have to set them at once.
             // Also one important thing here is that messages are set in descending order
             // in terms of `timestamp` of a message, that means a message with the most
             // recent time is added at index 0.
            prevMessageIndex: model.prevMsgIndex
            prevMessageTimestamp: model.prevMsgTimestamp
            prevMessageSenderId: model.prevMsgSenderId
            prevMessageContentType: model.prevMsgContentType
            prevMessageDeleted: model.prevMsgDeleted
            nextMessageIndex: model.nextMsgIndex
            nextMessageTimestamp: model.nextMsgTimestamp

            onOpenStickerPackPopup: {
                root.openStickerPackPopup(stickerPackId);
            }

            onShowReplyArea: {
                root.showReplyArea(messageId, author)
            }

            stickersLoaded: root.stickersLoaded

            onVisibleChanged: {
                if(!visible && model.editMode)
                    messageStore.setEditModeOff(model.id)
            }
        }
        header: {
            if (!root.isContactBlocked && root.isOneToOne && root.rootStore.oneToOneChatContact) {
                switch (root.rootStore.oneToOneChatContact.contactRequestState) {
                case Constants.ContactRequestState.None: // no break
                case Constants.ContactRequestState.Dismissed:
                    return sendContactRequestComponent
                case Constants.ContactRequestState.Received:
                    return acceptOrDeclineContactRequestComponent
                case Constants.ContactRequestState.Sent:
                    return pendingContactRequestComponent
                default:
                    break
                }
            }
            return null
        }
        onHeaderChanged: chatLogView.positionViewAtBeginning()
    }

    MessageDialog {
        id: sendingMsgFailedPopup
        standardButtons: StandardButton.Ok
        text: qsTr("Failed to send message.")
        icon: StandardIcon.Critical
    }

    Component {
        id: sendContactRequestComponent

        StatusButton {
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
            text: qsTr("Send Contact Request")
            onClicked: {
                Global.openContactRequestPopup(root.chatId, null)
            }
        }
    }

    Component {
        id: acceptOrDeclineContactRequestComponent

        RowLayout {
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

            StatusButton {
                text: qsTr("Reject Contact Request")
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    root.contactsStore.dismissContactRequest(root.chatId, "")
                }
            }

            StatusButton {
                text: qsTr("Accept Contact Request")
                onClicked: {
                    root.contactsStore.acceptContactRequest(root.chatId, "")
                }
            }
        }
    }

    Component {
        id: pendingContactRequestComponent

        StatusButton {
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
            enabled: false
            text: qsTr("Contact Request Pending...")
        }
    }
}
