import QtQuick 2.14

import QtQuick.Controls 2.3
import QtQuick.Controls 2.14 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQml.Models 2.3
import "../../../../shared"
import "../../../../imports"
import "./samples/"

ScrollView {
    id: scrollView
    
    property var messageList: MessagesData {}
    property bool loadingMessages: false

    contentItem: chatLogView
    anchors.fill: parent
    Layout.fillWidth: true
    Layout.fillHeight: true

    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    ListView {
        anchors.fill: parent
        spacing: 4
        id: chatLogView
        Layout.fillWidth: true
        Layout.fillHeight: true

        Connections {
            target: chatsModel
            onMessagesLoaded: {
                loadingMessages = false;
            }

            onActiveChannelChanged: {
                Qt.callLater( chatLogView.positionViewAtEnd )
            }

            onMessagePushed: {
                if (!chatLogView.atYEnd) {
                    // User has scrolled up, we don't want to scroll back
                    return
                }
            
                if(chatLogView.atYEnd)
                    Qt.callLater( chatLogView.positionViewAtEnd )
            }
        }

        onContentYChanged: {
            if(atYBeginning && !loadingMessages){
                loadingMessages = true;
                chatsModel.loadMoreMessages();
            }
        }


        model: messageListDelegate
        section.property: "fromAuthor"
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

        Message {
            id: msgDelegate
            chatId: model.chatId
            userName: model.userName
            message: model.message
            identicon: model.identicon
            isCurrentUser: model.isCurrentUser
            timestamp: model.timestamp
            sticker: model.sticker
            contentType: model.contentType
            authorCurrentMsg: msgDelegate.ListView.section
            authorPrevMsg: msgDelegate.ListView.previousSection
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
