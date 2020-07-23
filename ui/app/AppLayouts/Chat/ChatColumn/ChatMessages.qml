import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.13
import "../../../../shared"
import "../../../../imports"
import "../components"
import "./samples/"
import "./MessageComponents"

ScrollView {
    id: scrollView
    
    property var messageList: MessagesData {}
    property var appSettings
    property bool loadingMessages: false
    property real scrollY: chatLogView.visibleArea.yPosition * chatLogView.contentHeight

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
        Layout.fillWidth: true
        Layout.fillHeight: true

        Timer {
            id: timer
        }

        Rectangle {
            id: newMessagesBox
            color: Style.current.secondaryBackground
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            height: newMessagesText.height + clickHereText.height + 2 * Style.current.smallPadding
            width: 200
            radius: Style.current.radius

            StyledText {
                id: newMessagesText
                text: qsTr("New message(s) received")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                anchors.left: parent.left
                anchors.leftMargin: Style.current.smallPadding
                anchors.right: parent.right
                anchors.rightMargin: Style.current.smallPadding
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                font.pixelSize: 15
            }
            StyledText {
                id: clickHereText
                text: qsTr("Click here to scroll back down")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                anchors.left: parent.left
                anchors.leftMargin: Style.current.smallPadding
                anchors.right: parent.right
                anchors.rightMargin: Style.current.smallPadding
                anchors.top: newMessagesText.bottom
                anchors.topMargin: 0
                font.pixelSize: 12
                color: Style.current.darkGrey
            }

            MouseArea {
               cursorShape: Qt.PointingHandCursor
               anchors.fill: parent
               onClicked: {
                   newMessagesBox.visible = false
                   chatLogView.scrollToBottom(true)
               }
            }
        }

        onAtYEndChanged: {
            if (chatLogView.atYEnd) {
                newMessagesBox.visible = false
            }
        }

        function scrollToBottom(force, caller) {
            if (!force && !chatLogView.atYEnd) {
                // User has scrolled up, we don't want to scroll back
                return false
            }
            if (caller) {
                if (caller !== chatLogView.itemAtIndex(chatLogView.count - 1)) {
                    // If we have a caller, only accept its request if it's the last message
                    return false
                }
                // Add a small delay because images, even though they say they say they are loaed, they aren't shown yet
                timer.setTimeout(function() {
                    Qt.callLater(chatLogView.positionViewAtEnd)
                }, 100);
                return true
            }

            Qt.callLater(chatLogView.positionViewAtEnd)
            return true
        }


        Connections {

            target: chatsModel
            onMessagesLoaded: {
                loadingMessages = false;
            }

            onActiveChannelChanged: {
                chatLogView.scrollToBottom(true)
            }

            onSendingMessage: {
                chatLogView.scrollToBottom(true)
            }

            onNewMessagePushed: {
                if (!chatLogView.scrollToBottom()) {
                    newMessagesBox.visible = true
                }
            }

            onAppReady: {
                // Add an additionnal delay, since the app can be "ready" just milliseconds before the UI updated to show the chat
                timer.setTimeout(function() {
                    chatLogView.scrollToBottom(true)
                }, 500);
            }

            onMessageNotificationPushed: function(chatId, msg) {
                notificationWindow.notifyUser(chatId, msg)
            }
        }

        property var loadMsgs : Backpressure.oneInTime(chatLogView, 500, function() { 
            if(loadingMessages) return;
            loadingMessages = true;
            chatsModel.loadMoreMessages();
        });

        onContentYChanged: {
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
            function(left, right) { return left.clock < right.clock } // TODO: should be sorted by messageId
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

        ProfilePopup {
          id: profilePopup
        }

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
            profileClick: profilePopup.setPopupData.bind(profilePopup)
            messageId: model.messageId
            prevMessageIndex: {
                // This is used in order to have access to the previous message and determine the timestamp
                // we can't rely on the index because the sequence of messages is not ordered on the nim side
                if(msgDelegate.DelegateModel.itemsIndex > 0){
                    return messageListDelegate.items.get(msgDelegate.DelegateModel.itemsIndex - 1).model.index
                }
                return -1;
            }
            appSettings: scrollView.appSettings
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
