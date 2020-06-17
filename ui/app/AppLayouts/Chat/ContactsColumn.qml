import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtGraphicalEffects 1.12
import "../../../imports"
import "../../../shared"
import "./components"
import "./ContactsColumn"

Item {
    property alias chatGroupsListViewCount: channelList.channelListCount
    property alias searchStr: searchBox.text

    id: contactsColumn
    width: 300
    Layout.minimumWidth: 200
    Layout.fillHeight: true

    Text {
        id: title
        x: 772
        text: qsTr("Chat")
        anchors.top: parent.top
        anchors.topMargin: 17
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 17
    }

    PublicChatPopup {
        id: publicChatPopup
    }

    GroupChatPopup {
        id: groupChatPopup
    }

    PrivateChatPopup {
        id: privateChatPopup
    }

    SearchBox {
        id: searchBox
        anchors.top: parent.top
        anchors.topMargin: 59
        anchors.right: addChat.left
        anchors.rightMargin: Theme.padding
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
    }

    AddChat {
        id: "addChat"
    }

    StackLayout {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: searchBox.bottom
        anchors.topMargin: 16

        currentIndex: channelList.channelListCount > 0 ? 1 : 0

        EmptyView {}

        ChannelList {
            id: channelList
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:770;width:300}
}
##^##*/
