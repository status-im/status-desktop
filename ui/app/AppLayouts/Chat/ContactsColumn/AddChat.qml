import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../components"
AddButton {
    id: btnAdd
    width: 36
    height: 36

    onClicked: {
        let x = btnAdd.icon.x + btnAdd.icon.width / 2 - newChatMenu.width / 2
        newChatMenu.popup(x, btnAdd.icon.height + 10)
    }
    
    PopupMenu {
        id: newChatMenu
        Action {
            //% "Start new chat"
            text: qsTrId("start-new-chat")
            icon.source: "../../../img/new_chat.svg"
            icon.width: 20
            icon.height: 20
            onTriggered: privateChatPopup.open()
        }
        Action {
            //% "Start group chat"
            text: qsTrId("start-group-chat")
            icon.source: "../../../img/group_chat.svg"
            icon.width: 20
            icon.height: 20
            onTriggered: groupChatPopup.open()
        }
        Action {
            //% "Join public chat"
            text: qsTrId("new-public-group-chat")
            icon.source: "../../../img/public_chat.svg"
            icon.width: 20
            icon.height: 20
            onTriggered: publicChatPopup.open()
        }
        onAboutToHide: {
            btnAdd.icon.state = "default"
        }
    }
}
