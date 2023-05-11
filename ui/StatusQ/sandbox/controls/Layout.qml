import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1
import StatusQ.Popups 0.1

Column {
    spacing: 10

    StatusToolBar {
        width: 518
        headerContent: StatusChatInfoButton {
            width: Math.min(implicitWidth, parent.width)
            title: "Some contact"
            subTitle: "Contact"
            asset.color: Theme.palette.miscColor7
            type: StatusChatInfoButton.Type.OneToOneChat
        }
    }

    StatusToolBar {
        width: 518

        headerContent: StatusChatInfoButton {
            width: Math.min(implicitWidth, parent.width)
            title: "Muted public chat"
            subTitle: "Some subtitle"
            asset.color: Theme.palette.miscColor7
            type: StatusChatInfoButton.Type.PublicChat
            pinnedMessagesCount: 1
            muted: true
        }
    }


    StatusToolBar {
        notificationCount: 1
        hasUnseenNotifications: true
        width: 518

        headerContent: StatusChatInfoButton {
            width: Math.min(implicitWidth, parent.width)
            title: "Group chat"
            subTitle: "Group chat subtitle"
            asset.color: Theme.palette.miscColor7
            type: StatusChatInfoButton.Type.GroupChat
            pinnedMessagesCount: 1
        }
    }

    StatusToolBar {
        width: 518

        headerContent: StatusChatInfoButton {
            title: "Community chat"
            subTitle: "Some very long description text to see how the whole item wraps or ellides"
            asset.color: Theme.palette.miscColor7
            type: StatusChatInfoButton.Type.CommunityChat
            pinnedMessagesCount: 3
        }
    }

    StatusToolBar {
        headerContent: StatusChatInfoButton {
            title: "Very long chat name"
            asset.color: Theme.palette.miscColor7
            type: StatusChatInfoButton.Type.CommunityChat
            pinnedMessagesCount: 1234567891
        }
    }

    StatusToolBar {
        notificationCount: 1
        hasUnseenNotifications: true
        width: 518

        StatusTagSelector {
            namesModel: ListModel {
                ListElement {
                    publicId: "0x0"
                    name: "Maria"
                    icon: ""
                    isIdenticon: false
                    onlineStatus: 3
                    isReadonly: true
                    tagIcon: "crown"
                }
                ListElement {
                    publicId: "0x1"
                    name: "James"
                    icon: ""
                    isIdenticon: false
                    onlineStatus: 1
                    isReadonly: false
                    tagIcon: ""
                }
            }
            toLabelText: qsTr("To: ")
            warningText: qsTr("USER LIMIT REACHED")
        }
    }
}
