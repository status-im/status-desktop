import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.13

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

GridLayout {
    columns: 1
    columnSpacing: 5
    rowSpacing: 5

    StatusChatInfoToolBar {
        chatInfoButton.title: "Cryptokitties"        
        chatInfoButton.subTitle: "128 Members"
        chatInfoButton.asset.isImage: true
        chatInfoButton.asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"
        chatInfoButton.asset.color: Theme.palette.miscColor6

        popupMenu: StatusMenu {

            StatusAction {
                text: "Create channel"
                icon.name: "channel"
            }

            StatusAction {
                text: "Create category"
                icon.name: "channel-category"
            }

            StatusMenuSeparator {}

            StatusAction {
                text: "Invite people"
                icon.name: "share-ios"
                objectName: "invitePeople"
            }
        }
    }
}
