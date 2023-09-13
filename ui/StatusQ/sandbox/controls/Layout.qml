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

    Row {
        spacing: 5
        Button {
            id: btn
            text: "Append"
            onClicked: {
                buttons.append({
                    name: "Test community",
                    tooltipText: "Test Community"
                })
            }
        }

        QtObject {
            id: appSectionType
            readonly property int chat: 0
            readonly property int community: 1
            readonly property int wallet: 2
            readonly property int browser: 3
            readonly property int nodeManagement: 4
            readonly property int profileSettings: 5
        }

        StatusAppNavBar {

            sectionModel: ListModel {
                ListElement {sectionId: "chat"; sectionType: 0; name: "Chat"; active: true; image: ""; icon: "chat"; color: ""; hasNotification: true; notificationsCount: 12}
            }

            regularNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                autoExclusive: true
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
            }
        }

        StatusAppNavBar {

            communityTypeRole: "sectionType"
            communityTypeValue: appSectionType.community
            sectionModel: ListModel {
                ListElement {sectionId: "chat"; sectionType: 0; name: "Chat"; active: true; image: ""; icon: "chat"; color: ""; hasNotification: true; notificationsCount: 12}
                ListElement {sectionId: "0x0001"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: true; notificationsCount: 12}
                ListElement {sectionId: "wallet"; sectionType: 2; name: "Wallet"; active: false; image: ""; icon: "wallet"; color: ""; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "browser"; sectionType: 3; name: "Browser"; active: false; image: ""; icon: "bigger/browser"; color: ""; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "profile"; sectionType: 5; name: "Profile"; active: false; image: ""; icon: "bigger/settings"; color: ""; hasNotification: true; notificationsCount: 0}
            }

            property bool communityAdded: false

            filterRegularItem: function(item) {
                if(item.sectionType === appSectionType.community)
                    if(communityAdded)
                        return false
                    else
                        communityAdded = true

                return true
            }

            filterCommunityItem: function(item) {
                return item.sectionType === appSectionType.community
            }

            regularNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                autoExclusive: true
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
            }

            communityNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                autoExclusive: true
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                popupMenu: communityPopupMenu
            }
        }

        StatusAppNavBar {

            communityTypeRole: "sectionType"
            communityTypeValue: appSectionType.community
            sectionModel: ListModel {
                ListElement {sectionId: "chat"; sectionType: 0; name: "Chat"; active: true; image: ""; icon: "chat"; color: ""; hasNotification: true; notificationsCount: 12}
                ListElement {sectionId: "0x0001"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: true; notificationsCount: 12}
                ListElement {sectionId: "wallet"; sectionType: 2; name: "Wallet"; active: false; image: ""; icon: "wallet"; color: ""; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "browser"; sectionType: 3; name: "Browser"; active: false; image: ""; icon: "bigger/browser"; color: ""; hasNotification: false; notificationsCount: 0}
            }

            property bool communityAdded: false

            filterRegularItem: function(item) {
                if(item.sectionType === appSectionType.community)
                    if(communityAdded)
                        return false
                    else
                        communityAdded = true

                return true
            }

            filterCommunityItem: function(item) {
                return item.sectionType === appSectionType.community
            }

            regularNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                autoExclusive: true
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
            }

            communityNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                autoExclusive: true
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                popupMenu: communityPopupMenu
            }
        }


        StatusAppNavBar {

            communityTypeRole: "sectionType"
            communityTypeValue: appSectionType.community
            sectionModel: ListModel {
                ListElement {sectionId: "chat"; sectionType: 0; name: "Chat"; active: true; image: ""; icon: "chat"; color: ""; hasNotification: true; notificationsCount: 12}
                ListElement {sectionId: "0x0001"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "0x0002"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "0x0003"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "0x0004"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: true; notificationsCount: 0}
                ListElement {sectionId: "wallet"; sectionType: 2; name: "Wallet"; active: false; image: ""; icon: "wallet"; color: ""; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "browser"; sectionType: 3; name: "Browser"; active: false; image: ""; icon: "bigger/browser"; color: ""; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "profile"; sectionType: 5; name: "Profile"; active: false; image: ""; icon: "bigger/settings"; color: ""; hasNotification: false; notificationsCount: 0}
            }

            property bool communityAdded: false

            filterRegularItem: function(item) {
                if(item.sectionType === appSectionType.community)
                    if(communityAdded)
                        return false
                    else
                        communityAdded = true

                return true
            }

            filterCommunityItem: function(item) {
                return item.sectionType === appSectionType.community
            }

            regularNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                autoExclusive: true
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
            }

            communityNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                autoExclusive: true
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                popupMenu: communityPopupMenu
            }
        }

        StatusAppNavBar {

            communityTypeRole: "sectionType"
            communityTypeValue: appSectionType.community
            sectionModel: ListModel {
                ListElement {sectionId: "chat"; sectionType: 0; name: "Chat"; active: true; image: ""; icon: "chat"; color: ""; hasNotification: true; notificationsCount: 12}
                ListElement {sectionId: "0x0001"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: true; notificationsCount: 12}
                ListElement {sectionId: "0x0002"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "0x0003"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: true; notificationsCount: 0}
                ListElement {sectionId: "0x0004"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: true; notificationsCount: 1}
                ListElement {sectionId: "0x0005"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "0x0006"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: true; notificationsCount: 3}
                ListElement {sectionId: "0x0007"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: true; notificationsCount: 5}
                ListElement {sectionId: "0x0008"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: true; notificationsCount: 0}
                ListElement {sectionId: "0x0009"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "0x0010"; sectionType: 1; name: "Test Community"; active: false; image: ""; icon: ""; color: "#00ff00"; hasNotification: true; notificationsCount: 11}
                ListElement {sectionId: "wallet"; sectionType: 2; name: "Wallet"; active: false; image: ""; icon: "wallet"; color: ""; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "browser"; sectionType: 3; name: "Browser"; active: false; image: ""; icon: "bigger/browser"; color: ""; hasNotification: false; notificationsCount: 0}
                ListElement {sectionId: "profile"; sectionType: 5; name: "Profile"; active: false; image: ""; icon: "bigger/settings"; color: ""; hasNotification: true; notificationsCount: 0}
            }

            property bool communityAdded: false

            filterRegularItem: function(item) {
                if(item.sectionType === appSectionType.community)
                    if(communityAdded)
                        return false
                    else
                        communityAdded = true

                return true
            }

            filterCommunityItem: function(item) {
                return item.sectionType === appSectionType.community
            }

            regularNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                autoExclusive: true
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
            }

            communityNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                autoExclusive: true
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                popupMenu: communityPopupMenu
            }
        }
    }

    Component {
        id: communityPopupMenu

        StatusMenu {

            StatusAction {
                text: qsTr("Invite People")
                icon.name: "share-ios"
                objectName: "invitePeople"
            }

            StatusAction {
                text: qsTr("View Community")
                icon.name: "group"
            }

            StatusAction {
                text: qsTr("Edit Community")
                icon.name: "edit"
                enabled: false
            }

            StatusMenuSeparator {}

            StatusAction {
                text: qsTr("Leave Community")
                icon.name: "arrow-left"
                type: StatusAction.Type.Danger
            }
        }
    }
}
