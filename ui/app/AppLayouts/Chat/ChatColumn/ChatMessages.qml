import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Window 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.13
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "../components"
import "./samples/"
import "./MessageComponents"
import "../ContactsColumn"
import "../CommunityComponents"

Item {
    id: root
    anchors.fill: parent

    property alias chatLogView: chatLogView
    property alias scrollToMessage: chatLogView.scrollToMessage

    property var messageContextMenuInst
    property var messageList: MessagesData {}

    property real scrollY: chatLogView.visibleArea.yPosition * chatLogView.contentHeight
    property int newMessages: 0
    property int countOnStartUp: 0

    ListView {
        id: chatLogView
        anchors.fill: parent
        anchors.bottomMargin: Style.current.bigPadding
        spacing: appSettings.useCompactMode ? 0 : 4
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        verticalLayoutDirection: ListView.BottomToTop

        // This header and Connections is to create an invisible padding so that the chat identifier is at the top
        // The Connections is necessary, because doing the check inside the header created a binding loop (the contentHeight includes the header height
        // If the content height is smaller than the full height, we "show" the padding so that the chat identifier is at the top, otherwise we disable the Connections
        header: Item {
            height: 0
            width: chatLogView.width
        }

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

        property var scrollToMessage: function (messageId) {
            let item
            for (let i = 0; i < messageListDelegate.count; i++) {
                item = messageListDelegate.items.get(i)
                if (item.model.messageId === messageId) {
                    chatLogView.positionViewAtIndex(i, ListView.Center)
                    return
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            visible: chatLogView.visibleArea.heightRatio < 1
        }

        Connections {
            id: contentHeightConnection
            enabled: true
            target: chatLogView
            onContentHeightChanged: {
                chatLogView.checkHeaderHeight()
            }
            onHeightChanged: {
                chatLogView.checkHeaderHeight()
            }
        }

        Timer {
            id: timer
        }

        Button {
            readonly property int buttonPadding: 5

            id: scrollDownButton
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

            SVGImage {
                id: arrowImage
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: nbMessages.right
                source: "../../../img/leave_chat.svg"
                anchors.leftMargin: nbMessages.visible ? scrollDownButton.buttonPadding : 0
                rotation: -90

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Style.current.pillButtonTextColor
                }
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onPressed: mouse.accepted = false
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

        Connections {
            target: chatsModel

            onAppReady: {
                chatLogView.scrollToBottom(true)
            }
        }

        Connections {
            target: chatsModel.messageView

            onSendingMessageSuccess: {
                chatLogView.scrollToBottom(true)
            }

            onSendingMessageFailed: {
                sendingMsgFailedPopup.open();
            }

            onNewMessagePushed: {
                if (!chatLogView.scrollToBottom()) {
                    newMessages++
                }
            }
        }

        Connections {
            target: chatsModel.communities

            // Note:
            // Whole this Connection object (both slots) should be moved to the nim side.
            // Left here only cause we don't have a way to deal with translations on the nim side.

            onMembershipRequestChanged: function (communityId, communityName, accepted) {
                chatColumnLayout.currentNotificationChatId = null
                chatColumnLayout.currentNotificationCommunityId = communityId
                chatsModel.showOSNotification("Status",
                                              //% "You have been accepted into the ‘%1’ community"
                                              accepted ? qsTrId("you-have-been-accepted-into-the---1--community").arg(communityName) :
                                                         //% "Your request to join the ‘%1’ community was declined"
                                                         qsTrId("your-request-to-join-the---1--community-was-declined").arg(communityName),
                                              accepted? Constants.osNotificationType.acceptedIntoCommunity :
                                                        Constants.osNotificationType.rejectedByCommunity,
                                              communityId,
                                              "",
                                              "",
                                              appSettings.useOSNotifications)
            }

            onMembershipRequestPushed: function (communityId, communityName, pubKey) {
                chatColumnLayout.currentNotificationChatId = null
                chatColumnLayout.currentNotificationCommunityId = communityId
                //% "New membership request"
                chatsModel.showOSNotification(qsTrId("new-membership-request"),
                                              //% "%1 asks to join ‘%2’"
                                              qsTrId("-1-asks-to-join---2-").arg(Utils.getDisplayName(pubKey)).arg(communityName),
                                              Constants.osNotificationType.joinCommunityRequest,
                                              communityId,
                                              "",
                                              "",
                                              appSettings.useOSNotifications)
            }
        }

        property var loadMsgs : Backpressure.oneInTime(chatLogView, 500, function() {
            if(!messages.initialMessagesLoaded || messages.loadingHistoryMessages)
                return

            chatsModel.messageView.loadMoreMessages(chatId);
        });

        onContentYChanged: {
            scrollDownButton.visible = (contentHeight - (scrollY + height) > 400)
            if(scrollDownButton.visible && scrollY < 500){
                loadMsgs();
            }
        }

        model: messageListDelegate
        section.property: "sectionIdentifier"
        section.criteria: ViewSection.FullString
    }

    MessageDialog {
        id: sendingMsgFailedPopup
        standardButtons: StandardButton.Ok
        //% "Failed to send message."
        text: qsTrId("failed-to-send-message-")
        icon: StandardIcon.Critical
    }

    Timer {
        id: modelLoadingDelayTimer
        interval: 1000
        onTriggered: {
            root.countOnStartUp = messageListDelegate.count;
        }
    }

    DelegateModelGeneralized {
        id: messageListDelegate
        lessThan: [
            function(left, right) { return left.clock > right.clock }
        ]

        model: messages

        delegate: Message {
            id: msgDelegate
            fromAuthor: model.fromAuthor
            chatId: model.chatId
            userName: model.userName
            alias: model.alias
            localName: model.localName
            message: model.message
            plainText: model.plainText
            identicon: model.identicon
            isCurrentUser: model.isCurrentUser
            timestamp: model.timestamp
            sticker: model.sticker
            contentType: model.contentType
            replaces: model.replaces
            isEdited: model.isEdited
            outgoingStatus: model.outgoingStatus
            responseTo: model.responseTo
            authorCurrentMsg: msgDelegate.ListView.section
            // The previous message is actually the nextSection since we reversed the list order
            authorPrevMsg: msgDelegate.ListView.nextSection
            imageClick: imagePopup.openPopup.bind(imagePopup)
            messageId: model.messageId
            emojiReactions: model.emojiReactions
            linkUrls: model.linkUrls
            communityId: model.communityId
            hasMention: model.hasMention
            stickerPackId: model.stickerPackId
            pinnedMessage: model.isPinned
            pinnedBy: model.pinnedBy
            gapFrom: model.gapFrom
            gapTo: model.gapTo
            Component.onCompleted: {
                if ((root.countOnStartUp > 0) && (root.countOnStartUp - 1) < index) {
                    //new message, increment z order
                    z = index;
                }
            }
            messageContextMenu: root.messageContextMenuInst

            prevMessageIndex: {
                // This is used in order to have access to the previous message and determine the timestamp
                // we can't rely on the index because the sequence of messages is not ordered on the nim side
                if (msgDelegate.DelegateModel.itemsIndex < messageListDelegate.items.count - 1) {
                    return messageListDelegate.items.get(msgDelegate.DelegateModel.itemsIndex + 1).model.index
                }
                return -1;
            }
            nextMessageIndex: {
                if (msgDelegate.DelegateModel.itemsIndex < 1) {
                    return -1
                }
                return messageListDelegate.items.get(msgDelegate.DelegateModel.itemsIndex - 1).model.index
            }
            scrollToBottom: chatLogView.scrollToBottom
            timeout: model.timeout
        }
        Component.onCompleted: {
            modelLoadingDelayTimer.start();
        }
    }
}
