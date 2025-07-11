import QtQuick
import StatusQ.Core
import shared

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
