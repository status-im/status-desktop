import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../shared/status"
import "../components"
StatusRoundButton {
    id: btnAdd
    pressedIconRotation: 45
    icon.name: "plusSign"
    size: "medium"
    type: "secondary"
    width: 36
    height: 36


    onClicked: {
        btnAdd.state = "pressed"
        let x = btnAdd.iconX + btnAdd.icon.width / 2 - newChatMenu.width / 2
        newChatMenu.popup(x, btnAdd.icon.height + 14)
    }
    
    PopupMenu {
        id: newChatMenu
        Action {
            //% "Start new chat"
            text: qsTrId("start-new-chat")
            icon.source: "../../../img/new_chat.svg"
            icon.width: 20
            icon.height: 20
            onTriggered: openPopup(privateChatPopupComponent)
        }
        Action {
            //% "Start group chat"
            text: qsTrId("start-group-chat")
            icon.source: "../../../img/group_chat.svg"
            icon.width: 20
            icon.height: 20
            onTriggered: openPopup(groupChatPopupComponent)
        }
        Action {
            //% "Join public chat"
            text: qsTrId("new-public-group-chat")
            icon.source: "../../../img/public_chat.svg"
            icon.width: 20
            icon.height: 20
            onTriggered: openPopup(publicChatPopupComponent)
        }
        Action {
            enabled: appSettings.communitiesEnabled
            //% "Communities"
            text: qsTrId("communities")
            icon.source: "../../../img/communities.svg"
            icon.width: 20
            icon.height: 20
            onTriggered: {
                openPopup(communitiesPopupComponent)
            }
        }
        onAboutToHide: {
            btnAdd.state = "default"
        }
    }
}
