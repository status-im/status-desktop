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

    contentItem: chatLogView
    anchors.fill: parent
    Layout.fillWidth: true
    Layout.fillHeight: true

    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    function scrollToBottom(goToBottom) {
        chatLogView.positionViewAtEnd();
    }

    ListView {
        anchors.fill: parent
        spacing: 4
        id: chatLogView
        Layout.fillWidth: true
        Layout.fillHeight: true
        onCountChanged: {
            scrollToBottom();
        }
        model: messageListDelegate
    }

    DelegateModel {
        id: messageListDelegate
        model: messageList
        delegate: Message {
            userName: model.userName
            message: model.message
            identicon: model.identicon
            isCurrentUser: model.isCurrentUser
            repeatMessageInfo: model.repeatMessageInfo
            timestamp: model.timestamp
            sticker: model.sticker
            contentType: model.contentType
        }

        property var lessThan: function(left, right) { return left.clock < right.clock }

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
                messageListDelegate.sort(messageListDelegate.lessThan)
                scrollToBottom();
            }
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
