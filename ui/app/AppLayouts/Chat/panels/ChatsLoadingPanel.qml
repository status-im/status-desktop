import QtQuick 2.13
import StatusQ.Core 0.1
import shared 1.0

Loader {
    property var chatSectionModule

    active: !chatSectionModule.chatsLoaded
    height: active && item ? item.height : 0

    sourceComponent: Item {
        width: parent.width

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6
            StatusBaseText {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Loading chats...")
            }
            LoadingAnimation {
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
