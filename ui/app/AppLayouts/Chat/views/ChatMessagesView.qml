import QtQuick 2.13
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

    property bool stickersLoaded: false
    property alias chatLogView: chatLogView
    property bool isChatBlocked: false
    property bool isActiveChannel: false

    property var messageContextMenu

    signal openStickerPackPopup(string stickerPackId)
    signal showReplyArea(string messageId, string author)
    signal editModeChanged(bool editModeOn)

    QtObject {
        id: d

        readonly property real scrollY: chatLogView.visibleArea.yPosition * chatLogView.contentHeight
        readonly property bool isMostRecentMessageInViewport: chatLogView.visibleArea.yPosition >= 0.999 - chatLogView.visibleArea.heightRatio
        readonly property var chatDetails: chatContentModule.chatDetails || null

        readonly property var loadMoreMessagesIfScrollBelowThreshold: Backpressure.oneInTime(root, 100, function() {
            if(scrollY < 1000) messageStore.loadMoreMessages()
        })

        function markAllMessagesReadIfMostRecentMessageIsInViewport() {
            if (!isMostRecentMessageInViewport || !chatLogView.visible) {
                return
            }

            if (chatDetails && chatDetails.active && chatDetails.hasUnreadMessages &&
                !messageStore.messageSearchOngoing && messageStore.firstUnseenMessageLoaded) {
                chatContentModule.markAllMessagesRead()
            }
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
            chatLogView.positionViewAtIndex(messageIndex, ListView.Center)
            chatLogView.itemAtIndex(messageIndex).startMessageFoundAnimation()
        }

        function onScrollToFirstUnreadMessage(messageIndex) {
            if (d.isMostRecentMessageInViewport) {
                onScrollToMessage(messageIndex)
            }
        }
    }

    Connections {
        target: root.messageStore

        function onMessageSearchOngoingChanged() {
            d.markAllMessagesReadIfMostRecentMessageIsInViewport()
        }

        function onFirstUnseenMessageLoadedChanged() {
            d.markAllMessagesReadIfMostRecentMessageIsInViewport()
        }
    }

    Connections {
        target: !!d.chatDetails ? d.chatDetails : null

        function onActiveChanged() {
            d.markAllMessagesReadIfMostRecentMessageIsInViewport()
            d.loadMoreMessagesIfScrollBelowThreshold()
        }

        function onHasUnreadMessagesChanged() {
            if (!d.chatDetails.hasUnreadMessages) {
                return
            }

            // HACK: we call `addNewMessagesMarker` later because messages model
            // may not be yet propagated with unread messages when this signal is emitted
            if (chatLogView.visible) {
                if (!d.isMostRecentMessageInViewport) {
                    Qt.callLater(() => messageStore.addNewMessagesMarker())
                }
            } else {
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

        readonly property bool show: !messageStore.firstUnseenMessageLoaded ||
                                     !messageStore.initialMessagesLoaded
        active: show
        visible: show
        anchors.top: loadingMessagesIndicator.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        sourceComponent:
            MessagesLoadingView {
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
        cacheBuffer: height * 2 // cache 2 screens worth of items

        model: messageStore.messagesModel

        onContentYChanged: {
            scrollDownButton.visible = contentHeight - (d.scrollY + height) > 400
            d.loadMoreMessagesIfScrollBelowThreshold()
        }

        onCountChanged: d.markAllMessagesReadIfMostRecentMessageIsInViewport()

        onVisibleChanged: d.markAllMessagesReadIfMostRecentMessageIsInViewport()

        ScrollBar.vertical: StatusScrollBar {
            visible: chatLogView.visibleArea.heightRatio < 1
        }

        Button {
            id: scrollDownButton

            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding

            visible: false
            height: 32
            width: arrowImage.width + 2 * Style.current.halfPadding

            background: Rectangle {
                color: Style.current.buttonSecondaryColor
                border.width: 0
                radius: 16
            }

            onClicked: {
                scrollDownButton.visible = false
                chatLogView.positionViewAtBeginning()
            }

            StatusIcon {
                id: arrowImage
                anchors.centerIn: parent
                width: 24
                height: 24
                icon: "arrow-down"
                color: Style.current.pillButtonTextColor
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
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

            isActiveChannel: root.isActiveChannel
            isChatBlocked: root.isChatBlocked
            messageContextMenu: root.messageContextMenu

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
            messageTimestamp: model.timestamp
            messageOutgoingStatus: model.outgoingStatus
            resendError: model.resendError
            messageContentType: model.contentType
            pinnedMessage: model.pinned
            messagePinnedBy: model.pinnedBy
            reactionsModel: model.reactions
            sticker: model.sticker
            stickerPack: model.stickerPack
            editModeOn: model.editMode
            onEditModeOnChanged: root.editModeChanged(editModeOn)
            isEdited: model.isEdited
            linkUrls: model.links
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

            gapFrom: model.gapFrom
            gapTo: model.gapTo

             // This is possible since we have all data loaded before we load qml.
             // When we fetch messages to fulfill a gap we have to set them at once.
             // Also one important thing here is that messages are set in descending order
             // in terms of `timestamp` of a message, that means a message with the most
             // recent time is added at index 0.
            prevMessageIndex: prevMsgIndex
            prevMessageTimestamp: prevMsgTimestamp
            prevMessageSenderId: prevMsgSenderId
            prevMessageContentType: prevMsgContentType
            nextMessageIndex: nextMsgIndex
            nextMessageTimestamp: nextMsgTimestamp

            onOpenStickerPackPopup: {
                root.openStickerPackPopup(stickerPackId);
            }

            onShowReplyArea: {
                root.showReplyArea(messageId, author)
            }

            onImageClicked: Global.openImagePopup(image, messageContextMenu)

            stickersLoaded: root.stickersLoaded

            onVisibleChanged: {
                if(!visible && model.editMode)
                    messageStore.setEditModeOff(model.id)
            }
        }
    }

    MessageDialog {
        id: sendingMsgFailedPopup
        standardButtons: StandardButton.Ok
        text: qsTr("Failed to send message.")
        icon: StandardIcon.Critical
    }
}
