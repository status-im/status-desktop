import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.13
import QtGraphicalEffects 1.13
import "../../../../shared"
import "../../../../imports"
import "../components"
import "./samples/"
import "./MessageComponents"

ScrollView {
    id: root
    
    property var messageList: MessagesData {}
    property bool loadingMessages: false
    property real scrollY: chatLogView.visibleArea.yPosition * chatLogView.contentHeight
    property int newMessages: 0

    contentItem: chatLogView
    Layout.fillWidth: true
    Layout.fillHeight: true

    ScrollBar.vertical.policy: chatLogView.contentHeight > chatLogView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    ListView {
        id: chatLogView
        anchors.fill: parent
        anchors.bottomMargin: Style.current.bigPadding
        spacing: 4
        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: 10000
        Layout.fillWidth: true
        Layout.fillHeight: true

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
                root.newMessages = 0
                scrollDownButton.visible = false
                chatLogView.scrollToBottom(true)
            }

            StyledText {
                id: nbMessages
                visible: root.newMessages > 0
                width: visible ? implicitWidth : 0
                text: root.newMessages
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
            Qt.callLater(chatLogView.positionViewAtEnd)
            timer.setTimeout(function() {
                 Qt.callLater(chatLogView.positionViewAtEnd)
            }, 100);
            return true
        }


        Connections {

            target: chatsModel
            onMessagesLoaded: {
                loadingMessages = false;
            }

            onActiveChannelChanged: {
                Qt.callLater(chatLogView.scrollToBottom.bind(this, true))
            }

            onSendingMessage: {
                chatLogView.scrollToBottom(true)
            }

            onNewMessagePushed: {
                if (!chatLogView.scrollToBottom()) {
                    root.newMessages++
                }
            }

            onAppReady: {
                chatLogView.scrollToBottom(true)
            }

            onMessageNotificationPushed: function(chatId, msg, messageType, chatType, timestamp, identicon, username, hasMention) {
                if (appSettings.notificationSetting == Constants.notifyAllMessages || 
                    (appSettings.notificationSetting == Constants.notifyJustMentions && hasMention)) {
                    if (chatsModel.activeChannel.id == chatId && sLayout.currentIndex == Constants.appViewChat) {
                        return
                    }
                    notificationWindow.notifyUser(chatId, msg, messageType, chatType, timestamp, identicon, username)
                }
            }
        }

        property var loadMsgs : Backpressure.oneInTime(chatLogView, 500, function() {
            if(loadingMessages) return;
            loadingMessages = true;
            chatsModel.loadMoreMessages();
        });

        onContentYChanged: {
            scrollDownButton.visible = (contentHeight - (scrollY + height) > 400)
            if(scrollY < 500){
                loadMsgs();
            }
        }


        model: messageListDelegate
        section.property: "sectionIdentifier"
        section.criteria: ViewSection.FullString
    }

    DelegateModel {
        id: messageListDelegate
        property var lessThan: [
            function(left, right) { return left.clock < right.clock }
        ]

        property int sortOrder: 0
        onSortOrderChanged: items.setGroups(0, items.count, "unsorted")

        function insertPosition(lessThan, item) {
            var lower = 0
            var upper = items.count
            while (lower < upper) {
                var middle = Math.floor(lower + (upper - lower) / 2)
                var result = lessThan(item.model, items.get(middle).model);
                if (result) {
                    upper = middle
                } else {
                    lower = middle + 1
                }
            }
            return lower
        }

        function sort(lessThan) {
            while (unsortedItems.count > 0) {
                var item = unsortedItems.get(0)
                var index = insertPosition(lessThan, item)
                item.groups = "items"
                items.move(item.itemsIndex, index)
            }
        }

        items.includeByDefault: false
        groups: DelegateModelGroup {
            id: unsortedItems
            name: "unsorted"
            includeByDefault: true
            onChanged: {
                if (messageListDelegate.sortOrder == messageListDelegate.lessThan.length)
                    setGroups(0, count, "items")
                else {
                    messageListDelegate.sort(messageListDelegate.lessThan[messageListDelegate.sortOrder])
                }
            }
        }
        model: messageList

        delegate: Message {
            id: msgDelegate
            fromAuthor: model.fromAuthor
            chatId: model.chatId
            userName: model.userName
            message: model.message
            plainText: model.plainText
            identicon: model.identicon
            isCurrentUser: model.isCurrentUser
            timestamp: model.timestamp
            sticker: model.sticker
            contentType: model.contentType
            outgoingStatus: model.outgoingStatus
            responseTo: model.responseTo
            authorCurrentMsg: msgDelegate.ListView.section
            authorPrevMsg: msgDelegate.ListView.previousSection
            imageClick: imagePopup.openPopup.bind(imagePopup)
            messageId: model.messageId
            emojiReactions: model.emojiReactions
            prevMessageIndex: {
                // This is used in order to have access to the previous message and determine the timestamp
                // we can't rely on the index because the sequence of messages is not ordered on the nim side
                if(msgDelegate.DelegateModel.itemsIndex > 0){
                    return messageListDelegate.items.get(msgDelegate.DelegateModel.itemsIndex - 1).model.index
                }
                return -1;
            }
            scrollToBottom: chatLogView.scrollToBottom
            timeout: model.timeout
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
