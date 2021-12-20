import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Window 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.13
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3

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
    //anchors.fill: parent

    property var store
    property var messageStore

    property alias chatLogView: chatLogView
    property alias scrollToMessage: chatLogView.scrollToMessage

    property var messageContextMenuInst

    property real scrollY: chatLogView.visibleArea.yPosition * chatLogView.contentHeight
    property int newMessages: 0

    ListView {
        id: chatLogView
        anchors.fill: parent
        spacing: 0
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

        property var scrollToMessage: function (messageId, isSearch = false) {
            // Not Refactored Yet
//            delayPositioningViewTimer.msgId = messageId;
//            delayPositioningViewTimer.isSearch = isSearch;
//            delayPositioningViewTimer.restart();
        }

//        Timer {
//            id: delayPositioningViewTimer
//            interval: 1000
//            property string msgId
//            property bool isSearch
//            onTriggered: {
//                let item
//                for (let i = 0; i < messages.rowCount(); i++) {
//                    item = messageListDelegate.items.get(i);
//                    if (item.model.messageId === msgId) {
//                        chatLogView.positionViewAtIndex(i, ListView.Beginning);
//                        if (isSearch) {
//                            chatLogView.itemAtIndex(i).startMessageFoundAnimation();
//                        }
//                    }
//                }
//                msgId = "";
//                isSearch = false;
//            }
//        }

//        ScrollBar.vertical: ScrollBar {
//            visible: chatLogView.visibleArea.heightRatio < 1
//        }

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

//        Button {
//            readonly property int buttonPadding: 5

//            id: scrollDownButton
//            visible: false
//            height: 32
//            width: nbMessages.width + arrowImage.width + 2 * Style.current.halfPadding + (nbMessages.visible ? scrollDownButton.buttonPadding : 0)
//            anchors.bottom: parent.bottom
//            anchors.right: parent.right
//            anchors.rightMargin: Style.current.padding
//            background: Rectangle {
//                color: Style.current.buttonSecondaryColor
//                border.width: 0
//                radius: 16
//            }
//            onClicked: {
//                newMessages = 0
//                scrollDownButton.visible = false
//                chatLogView.scrollToBottom(true)
//            }

//            StyledText {
//                id: nbMessages
//                visible: newMessages > 0
//                width: visible ? implicitWidth : 0
//                text: newMessages
//                anchors.verticalCenter: parent.verticalCenter
//                anchors.left: parent.left
//                color: Style.current.pillButtonTextColor
//                font.pixelSize: 15
//                anchors.leftMargin: Style.current.halfPadding
//            }

//            SVGImage {
//                id: arrowImage
//                width: 24
//                height: 24
//                anchors.verticalCenter: parent.verticalCenter
//                anchors.left: nbMessages.right
//                source: Style.svg("leave_chat")
//                anchors.leftMargin: nbMessages.visible ? scrollDownButton.buttonPadding : 0
//                rotation: -90

//                ColorOverlay {
//                    anchors.fill: parent
//                    source: parent
//                    color: Style.current.pillButtonTextColor
//                }
//            }

//            MouseArea {
//                cursorShape: Qt.PointingHandCursor
//                anchors.fill: parent
//                onPressed: mouse.accepted = false
//            }
//        }

        function scrollToBottom(force, caller) {
            // Not Refactored Yet
//            if (!force && !chatLogView.atYEnd) {
//                // User has scrolled up, we don't want to scroll back
//                return false
//            }
//            if (caller && caller !== chatLogView.itemAtIndex(chatLogView.count - 1)) {
//                // If we have a caller, only accept its request if it's the last message
//                return false
//            }
//            // Call this twice and with a timer since the first scroll to bottom might have happened before some stuff loads
//            // meaning that the scroll will not actually be at the bottom on switch
//            // Add a small delay because images, even though they say they say they are loaed, they aren't shown yet
//            Qt.callLater(chatLogView.positionViewAtBeginning)
//            timer.setTimeout(function() {
//                Qt.callLater(chatLogView.positionViewAtBeginning)
//            }, 100);
            return true
        }

//        Connections {
        // Not Refactored Yet
//            target: root.store.chatsModelInst

//            onAppReady: {
//                chatLogView.scrollToBottom(true)
//            }
//        }

//        Connections {
        // Not Refactored Yet
//            target: root.store.chatsModelInst.messageView

//            onSendingMessageSuccess: {
//                chatLogView.scrollToBottom(true)
//            }

//            onSendingMessageFailed: {
//                sendingMsgFailedPopup.open();
//            }

//            onNewMessagePushed: {
//                if (!chatLogView.scrollToBottom()) {
//                    newMessages++
//                }
//            }
//        }

//        Connections {
        // Not Refactored Yet
//            target: root.store.chatsModelInst.communities

//            // Note:
//            // Whole this Connection object (both slots) should be moved to the nim side.
//            // Left here only cause we don't have a way to deal with translations on the nim side.

//            onMembershipRequestChanged: function (communityId, communityName, accepted) {
//                chatColumnLayout.currentNotificationChatId = null
//                chatColumnLayout.currentNotificationCommunityId = communityId

//                const title = "Status"
//                const message = //% "You have been accepted into the ‘%1’ community"
//                              accepted ? qsTrId("you-have-been-accepted-into-the---1--community").arg(communityName) :
//                                         //% "Your request to join the ‘%1’ community was declined"
//                                         qsTrId("your-request-to-join-the---1--community-was-declined").arg(communityName)

//                if (Qt.platform.os === "linux") {
//                    // Linux Notifications are not implemented in Nim/C++ yet
//                    return systemTray.showMessage(title, message, systemTray.icon.source, 4000)
//                }

//                root.store.chatsModelInst.showOSNotification(title,
//                                              message,
//                                              accepted? Constants.osNotificationType.acceptedIntoCommunity :
//                                                        Constants.osNotificationType.rejectedByCommunity,
//                                              communityId,
//                                              "",
//                                              "",
//                                              localAccountSensitiveSettings.useOSNotifications)
//            }

//            onMembershipRequestPushed: function (communityId, communityName, pubKey) {
//                chatColumnLayout.currentNotificationChatId = null
//                chatColumnLayout.currentNotificationCommunityId = communityId

//                //% "New membership request"
//                const title = qsTrId("new-membership-request")
//                //% "%1 asks to join ‘%2’"
//                const message = qsTrId("-1-asks-to-join---2-").arg(Utils.getDisplayName(pubKey)).arg(communityName)

//                if (Qt.platform.os === "linux") {
//                    // Linux Notifications are not implemented in Nim/C++ yet
//                    return systemTray.showMessage(title, message, systemTray.icon.source, 4000)
//                }

//                root.store.chatsModelInst.showOSNotification(title,
//                                              message,
//                                              Constants.osNotificationType.joinCommunityRequest,
//                                              communityId,
//                                              "",
//                                              "",
//                                              localAccountSensitiveSettings.useOSNotifications)
//            }
//        }

        // Not Refactored Yet
//        property var loadMsgs : Backpressure.oneInTime(chatLogView, 500, function() {
//            if(!messages.initialMessagesLoaded || messages.loadingHistoryMessages)
//                return

//            root.store.chatsModelInst.messageView.loadMoreMessages(chatId);
//        });

//        onContentYChanged: {
//            scrollDownButton.visible = (contentHeight - (scrollY + height) > 400)
//            if(scrollDownButton.visible && scrollY < 500){
//                loadMsgs();
//            }
//        }

        model: messageStore.messageModule.model
        section.property: "sectionIdentifier"
        section.criteria: ViewSection.FullString

        // Not Refactored Yet
        //Component.onCompleted: scrollToBottom(true)

        delegate: MessageView {
            id: msgDelegate

            messageStore: root.messageStore
            messageContextMenu: messageContextMenuInst

            messageId: model.id
            responseToMessageWithId: model.responseToMessageWithId
            senderId: model.senderId
            senderDisplayName: model.senderDisplayName
            senderLocalName: model.senderLocalName
            senderIcon: model.senderIcon
            isSenderIconIdenticon: model.isSenderIconIdenticon
            amISender: model.amISender
            message: model.messageText
            messageImage: model.messageImage
            messageTimestamp: model.timestamp
            messageOutgoingStatus: model.outgoingStatus
            messageContentType: model.contentType
            pinnedMessage: model.pinned
            reactionsModel: model.reactions

            // This is possible since we have all data loaded before we load qml.
            // When we fetch messages to fulfill a gap we have to set them at once.
            prevMessageIndex: index - 1
            prevMessageAsJsonObj: messageStore.getMessageByIndexAsJson(index - 1)
            nextMessageIndex: index + 1
            nextMessageAsJsonObj: messageStore.getMessageByIndexAsJson(index + 1)
        }
    }

//    MessageDialog {
//        id: sendingMsgFailedPopup
//        standardButtons: StandardButton.Ok
//        //% "Failed to send message."
//        text: qsTrId("failed-to-send-message-")
//        icon: StandardIcon.Critical
//    }
}
