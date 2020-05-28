import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../shared"
import "../../../../imports"
import "../components"

Item {
    property alias channelListCount: chatGroupsListView.count
    id: chatGroupsContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    ListView {
        id: chatGroupsListView
        anchors.topMargin: 24
        anchors.fill: parent
        model: chatsModel.chats
        delegate: Channel {}
        onCountChanged: {
            if (count > 0) {
                currentIndex = 0;
            }
        }
    }
}