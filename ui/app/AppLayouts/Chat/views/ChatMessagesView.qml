import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Window 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.13
import QtGraphicalEffects 1.13
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

    property bool stickersLoaded: false
    property alias chatLogView: chatLogView
    property bool isChatBlocked: false
    property bool isActiveChannel: false

    property var messageContextMenu

    property real scrollY: chatLogView.visibleArea.yPosition * chatLogView.contentHeight
    property int newMessages: 0

    property int countOnStartUp: 0
    signal openStickerPackPopup(string stickerPackId)
    signal showReplyArea(string messageId, string author)

    Connections {
        target: root.messageStore.messageModule

        function onMessageSuccessfullySent() {
            chatLogView.scrollToBottom(true)
        }

        function onSendingMessageFailed() {
            sendingMsgFailedPopup.open()
        }

        function onScrollMessagesUp() {
            chatLogView.positionViewAtEnd()
        }

        function onScrollToMessage(messageIndex) {
            chatLogView.positionViewAtIndex(messageIndex, ListView.Center);
            chatLogView.itemAtIndex(messageIndex).startMessageFoundAnimation();
        }

        // Not Refactored Yet
        //            onNewMessagePushed: {
        //                if (!chatLogView.scrollToBottom()) {
        //                    newMessages++
        //                }
        //            }
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

    StatusListView {
        id: chatLogView
        objectName: "chatLogView"
        anchors.top: loadingMessagesIndicator.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0
        verticalLayoutDirection: ListView.BottomToTop

        function checkHeaderHeight() {
            if (!chatLogView.headerItem) {
                return
            }

            if (chatLogView.contentItem.height - chatLogView.headerItem.height < chatLogView.height) {
                chatLogView.headerItem.height = chatLogView.height - (chatLogView.contentItem.height - chatLogView.headerItem.height) - 36
            } else {
                chatLogView.headerItem.height = 0
            }
        }

        function scrollToBottom(force, caller) {
            if (!force && !chatLogView.atYEnd) {
                // User has scrolled up, we don't want to scroll back
                return false
            }
            if (caller && caller !== chatLogView.itemAtIndex(chatLogView.count - 1)) {
                // If we have a caller, only accept its request if it's the last message
                return false
            }
            // Call this twice and with a timer since the first scroll to bottom might have happened before some stuff loads
            // meaning that the scroll will not actually be at the bottom on switch
            // Add a small delay because images, even though they say they say they are loaed, they aren't shown yet
            Qt.callLater(chatLogView.positionViewAtBeginning)
            timer.setTimeout(function() {
                Qt.callLater(chatLogView.positionViewAtBeginning)
            }, 100);
            return true
        }

        model: messageStore.messagesModel

        Component.onCompleted: chatLogView.scrollToBottom(true)

        onContentYChanged: {
            scrollDownButton.visible = contentHeight - (scrollY + height) > 400
            let loadMore = scrollDownButton.visible && scrollY < 500
            if(loadMore){
                messageStore.loadMoreMessages()
            }
        }

        ScrollBar.vertical: StatusScrollBar {
            visible: chatLogView.visibleArea.heightRatio < 1
        }

        // This header and Connections is to create an invisible padding so that the chat identifier is at the top
        // The Connections is necessary, because doing the check inside the header created a binding loop (the contentHeight includes the header height
        // If the content height is smaller than the full height, we "show" the padding so that the chat identifier is at the top, otherwise we disable the Connections
        header: Item {
            height: 0
            width: chatLogView.width
        }

        //        Connections {
        //            id: contentHeightConnection
        //            enabled: true
        //            target: chatLogView
        //            onContentHeightChanged: {
        //                chatLogView.checkHeaderHeight()
        //            }
        //            onHeightChanged: {
        //                chatLogView.checkHeaderHeight()
        //            }
        //        }

        Timer {
            id: timer
        }

        Button {
            id: scrollDownButton

            readonly property int buttonPadding: 5

            visible: false
            height: 32
            width: nbMessages.width + arrowImage.width + 2 * Style.current.halfPadding + (nbMessages.visible ? scrollDownButton.buttonPadding : 0)
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            background: Rectangle {
                color: Style.current.buttonSecondaryColor
                border.width: 0
                radius: 16
            }

            onClicked: {
                newMessages = 0
                scrollDownButton.visible = false
                chatLogView.scrollToBottom(true)
            }

            StyledText {
                id: nbMessages
                visible: newMessages > 0
                width: visible ? implicitWidth : 0
                text: newMessages
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                color: Style.current.pillButtonTextColor
                font.pixelSize: 15
                anchors.leftMargin: Style.current.halfPadding
            }

            StatusIcon {
                id: arrowImage
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: nbMessages.right
                icon: "arrow-down"
                anchors.leftMargin: nbMessages.visible ? scrollDownButton.buttonPadding : 0
                color: Style.current.pillButtonTextColor
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onPressed: mouse.accepted = false
            }
        }

        //        Connections {
        // Not Refactored Yet
        //            target: root.rootStore.chatsModelInst

        //            onAppReady: {
        //                chatLogView.scrollToBottom(true)
        //            }
        //        }

        delegate: MessageView {
            id: msgDelegate

            width: ListView.view.width
            height: implicitHeight

            objectName: "chatMessageViewDelegate"
            rootStore: root.rootStore
            messageStore: root.messageStore
            usersStore: root.usersStore
            contactsStore: root.contactsStore
            channelEmoji: root.channelEmoji
            emojiPopup: root.emojiPopup
            chatLogView: ListView.view

            isActiveChannel: root.isActiveChannel
            isChatBlocked: root.isChatBlocked
            messageContextMenu: root.messageContextMenu

            itemIndex: index
            messageId: model.id
            communityId: model.communityId
            responseToMessageWithId: model.responseToMessageWithId
            responseToExistingMessage: model.responseToExistingMessage
            senderId: model.senderId
            senderDisplayName: model.senderDisplayName
            senderOptionalName: model.senderOptionalName
            senderIsEnsVerified: model.senderEnsVerified
            senderIcon: model.senderIcon
            senderIsAdded: model.senderIsAdded
            senderTrustStatus: model.senderTrustStatus
            amISender: model.amISender
            messageText: model.messageText
            messageImage: model.messageImage
            messageTimestamp: model.timestamp
            messageOutgoingStatus: model.outgoingStatus
            messageContentType: model.contentType
            pinnedMessage: model.pinned
            messagePinnedBy: model.pinnedBy
            reactionsModel: model.reactions
            sticker: model.sticker
            stickerPack: model.stickerPack
            editModeOn: model.editMode
            isEdited: model.isEdited
            linkUrls: model.links
            messageAttachments: model.messageAttachments
            transactionParams: model.transactionParameters
            hasMention: model.mentionedUsersPks.split(" ").includes(root.rootStore.userProfileInst.pubKey)

            gapFrom: model.gapFrom
            gapTo: model.gapTo

            // This is possible since we have all data loaded before we load qml.
            // When we fetch messages to fulfill a gap we have to set them at once.
            // Also one important thing here is that messages are set in descending order
            // in terms of `timestamp` of a message, that means a message with the most
            // recent time is added at index 0.
            prevMessageIndex: model.prevMsgIndex
            prevMessageAsJsonObj: messageStore.getMessageByIndexAsJson(model.prevMsgIndex)
            prevMsgTimestamp: model.prevMsgTimestamp
            nextMessageIndex: model.nextMsgIndex
            nextMessageAsJsonObj: messageStore.getMessageByIndexAsJson(model.nextMsgIndex)

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
