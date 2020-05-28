import QtQuick 2.14
import QtQuick.Controls 2.3
import QtQuick.Controls 2.14 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../shared"
import "../../../../imports"
import "./samples/"

ScrollView {
    property var messageList: MessagesData {}

    anchors.fill: parent
    Layout.fillWidth: true
    Layout.fillHeight: true

    ScrollBar.vertical.policy: chatLogView.contentHeight > chatLogView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    ListView {
        anchors.fill: parent
        spacing: 4
        id: chatLogView
        model: messageList
        Layout.fillWidth: true
        Layout.fillHeight: true
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
        highlightFollowsCurrentItem: true

        onCountChanged: {
            if (!this.atYEnd) {
                // User has scrolled up, we don't want to scroll back
                return
            }

            // positionViewAtEnd doesn't work well. Instead, we use highlightFollowsCurrentItem
            // and set the current Item/Index to the latest item
            while (this.currentIndex < this.count - 1) {
                this.incrementCurrentIndex()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
