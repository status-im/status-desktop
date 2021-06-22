import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1
import StatusQ.Popups 0.1

Rectangle {
    id: demoApp
    height: 602
    width: 902
    border.width: 1
    border.color: Theme.palette.baseColor2

    Row {
        anchors.top: demoApp.top
        anchors.left: demoApp.left
        anchors.topMargin: 14
        anchors.leftMargin: 14

        spacing: 6
        z: statusAppLayout.z + 1

        Rectangle {
            color: "#E24640"
            height: 12
            width: 12
            radius: 6
        }
        Rectangle {
            color: "#FFC12F"
            height: 12
            width: 12
            radius: 6
        }
        Rectangle {
            color: "#2ACB42"
            height: 12
            width: 12
            radius: 6
        }
    }


    StatusAppLayout {
        id: statusAppLayout
        anchors.top: demoApp.top
        anchors.left: demoApp.left
        anchors.topMargin: demoApp.border.width
        anchors.leftMargin: demoApp.border.width

        height: demoApp.height - demoApp.border.width * 2
        width: demoApp.width - demoApp.border.width * 2

        appNavBar: StatusAppNavBar {

            id: navBar

            navBarChatButton: StatusNavBarTabButton {
                icon.name: "chat"
                tooltip.text: "Chat"
                checked: appView.sourceComponent == statusAppChatView
                onClicked: {
                    appView.sourceComponent = statusAppChatView
                }
            }

            navBarCommunityTabButtons.model: ListModel {
                ListElement {
                    name: "Status Community"
                    tooltipText: "Status Community"
                }
            }

            navBarCommunityTabButtons.delegate: StatusNavBarTabButton {
                id: communityBtn
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.name
                tooltip.text: model.tooltipText
                icon.color: Theme.palette.miscColor6
                icon.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
                checked: appView.sourceComponent == statusAppCommunityView
                onClicked: {
                    appView.sourceComponent = statusAppCommunityView
                }

                popupMenu: StatusPopupMenu {

                    StatusMenuItem {
                        text: qsTr("Invite People")
                        icon.name: "share-ios"
                    }

                    StatusMenuItem {
                        text: qsTr("View Community")
                        icon.name: "group"
                    }

                    StatusMenuItem {
                        text: qsTr("Edit Community")
                        icon.name: "edit"
                        enabled: false
                    }

                    StatusMenuSeparator {}

                    StatusMenuItem {
                        text: qsTr("Leave Community")
                        icon.name: "arrow-right"
                        icon.width: 14
                        iconRotation: 180
                        type: StatusMenuItem.Type.Danger
                    }
                }

            }

            navBarTabButtons: [
                StatusNavBarTabButton {
                    icon.name: "wallet"
                    tooltip.text: "Wallet"
                },
                StatusNavBarTabButton {
                    icon.name: "browser"
                    tooltip.text: "Browser"
                },
                StatusNavBarTabButton {
                    icon.name: "status-update"
                    tooltip.text: "Timeline"
                },
                StatusNavBarTabButton {
                    id: profileNavButton
                    icon.name: "profile"
                    badge.visible: true
                    badge.anchors.rightMargin: 4
                    badge.anchors.topMargin: 5
                    badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusAppNavBar.backgroundColor
                    badge.border.width: 2

                    tooltip.text: "Profile"

                    checked: appView.sourceComponent == statusAppProfileSettingsView
                    onClicked: {
                        appView.sourceComponent = statusAppProfileSettingsView
                    }
                }
            ]
        }

        appView: Loader {
            id: appView
            anchors.fill: parent
            sourceComponent: statusAppChatView
        }
    }

    Component {
        id: statusAppChatView

        StatusAppTwoPanelLayout {

            leftPanel: Item {
                anchors.fill: parent

                StatusNavigationPanelHeadline {
                    id: headline
                    anchors.top: parent.top
                    anchors.topMargin: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Chat"
                }

                StatusChatList {
                    anchors.top: headline.bottom
                    anchors.topMargin: 16
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter

                    chatListItems.model: demoChatListItems
                    selectedChatId: "0"
                    onChatItemSelected: selectedChatId = id
                    onChatItemUnmuted: {
                        for (var i = 0; i < demoChatListItems.count; i++) {
                            let item = demoChatListItems.get(i);
                            if (item.chatId === id) {
                                demoChatListItems.setProperty(i, "muted", false)
                            }
                        }
                    }
                }
            }

            rightPanel: Item {
                anchors.fill: parent

                StatusChatToolBar {
                    anchors.top: parent.top
                    width: parent.width

                    chatInfoButton.title: "Amazing Funny Squirrel"        
                    chatInfoButton.subTitle: "Contact"
                    chatInfoButton.icon.color: Theme.palette.miscColor7
                    chatInfoButton.type: StatusChatInfoButton.Type.OneToOneChat
                    chatInfoButton.pinnedMessagesCount: 1

                    notificationCount: 1

                    onNotificationButtonClicked: notificationCount = 0

                    popupMenu: StatusPopupMenu {
                        id: contextMenu

                        StatusMenuItem {
                            text: "Mute Chat"
                            icon.name: "notification"
                        }
                        StatusMenuItem {
                            text: "Mark as Read"
                            icon.name: "checkmark-circle"
                        }
                        StatusMenuItem {
                            text: "Clear History"
                            icon.name: "close-circle"
                        }

                        StatusMenuSeparator {}

                        StatusMenuItem {
                            text: "Leave Chat"
                            icon.name: "arrow-right"
                            icon.width: 14
                            iconRotation: 180
                            type: StatusMenuItem.Type.Danger
                        }
                    }
                }
            }
        }
    }

    Component {
        id: statusAppCommunityView

        StatusAppTwoPanelLayout {

            leftPanel: Item {
                id: leftPanel
                anchors.fill: parent

                StatusChatInfoToolBar {
                    id: statusChatInfoToolBar

                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter

                    chatInfoButton.title: "CryptoKitties"
                    chatInfoButton.subTitle: "128 Members"
                    chatInfoButton.image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
                    chatInfoButton.icon.color: Theme.palette.miscColor6
                    chatInfoButton.onClicked: demoCommunityDetailModal.open()

                    popupMenu: StatusPopupMenu {

                        StatusMenuItem {
                            text: "Create channel"
                            icon.name: "channel"
                        }

                        StatusMenuItem {
                            text: "Create category"
                            icon.name: "channel-category"
                        }

                        StatusMenuSeparator {}

                        StatusMenuItem {
                            text: "Invite people"
                            icon.name: "share-ios"
                        }

                    }
                }

                ScrollView {
                    id: scrollView

                    anchors.top: statusChatInfoToolBar.bottom
                    anchors.topMargin: 8
                    anchors.bottom: parent.bottom
                    width: leftPanel.width

                    contentHeight: communityCategories.height
                    clip: true

                    StatusChatListAndCategories {
                        id: communityCategories
                        height: implicitHeight > (leftPanel.height - 64) ? implicitHeight + 8 : leftPanel.height - 64
                        width: leftPanel.width

                        chatList.model: demoCommunityChatListItems
                        categoryList.model: demoCommunityCategoryItems

                        showCategoryActionButtons: true
                        onChatItemSelected: selectedChatId = id

                        categoryPopupMenu: StatusPopupMenu {

                            property string categoryId

                            StatusMenuItem {
                                text: "Mute Category"
                                icon.name: "notification"
                            }

                            StatusMenuItem { 
                                text: "Mark as Read"
                                icon.name: "checkmark-circle"
                            }

                            StatusMenuItem { 
                                text: "Edit Category"
                                icon.name: "edit"
                            }

                            StatusMenuSeparator {}

                            StatusMenuItem {
                                text: "Delete Category"
                                icon.name: "delete"
                                type: StatusMenuItem.Type.Danger
                            }
                        }


                        popupMenu: StatusPopupMenu {
                            StatusMenuItem {
                                text: "Create channel"
                                icon.name: "channel"
                            }

                            StatusMenuItem {
                                text: "Create category"
                                icon.name: "channel-category"
                            }

                            StatusMenuSeparator {}

                            StatusMenuItem {
                                text: "Invite people"
                                icon.name: "share-ios"
                            }
                        }
                    }
                }
            }

            rightPanel: Item {
                anchors.fill: parent

                StatusChatToolBar {
                    anchors.top: parent.top
                    width: parent.width

                    chatInfoButton.title: "general"        
                    chatInfoButton.subTitle: "Community Chat"
                    chatInfoButton.icon.color: Theme.palette.miscColor6
                    chatInfoButton.type: StatusChatInfoButton.Type.CommunityChat
                }
            }
        }
    }

    Component {
        id: statusAppProfileSettingsView

        StatusAppTwoPanelLayout {

            leftPanel: Item {
                anchors.fill: parent

                StatusNavigationPanelHeadline {
                    id: profileHeadline
                    anchors.top: parent.top
                    anchors.topMargin: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Profile"
                }

                ScrollView {
                    anchors.top: profileHeadline.bottom
                    anchors.topMargin: 16
                    anchors.bottom: parent.bottom
                    width: parent.width

                    contentHeight: profileMenuItems.height + 8
                    contentWidth: parent.width
                    clip: true

                    Column {
                        id: profileMenuItems
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4

                        Repeater {
                            model: demoProfileGeneralMenuItems
                            delegate: StatusNavigationListItem {
                                title: model.title
                                icon.name: model.icon
                            }
                        }

                        StatusListSectionHeadline { text: "Settings" }

                        Repeater {
                            model: demoProfileSettingsMenuItems
                            delegate: StatusNavigationListItem {
                                title: model.title
                                icon.name: model.icon
                            }
                        }

                        Item { 
                            id: invisibleSeparator
                            height: 16
                            width: parent.width
                        }

                        Repeater {
                            model: demoProfileOtherMenuItems
                            delegate: StatusNavigationListItem {
                                title: model.title
                                icon.name: model.icon
                            }
                        }
                    }
                }
            }

            rightPanel: Item {
                anchors.fill: parent
            }
        }
    }

    StatusModal {
        id: demoCommunityDetailModal

        anchors.centerIn: parent

        header.title: "Cryptokitties"        
        header.subTitle: "Public Community"
        header.image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"

        content: Column {
            width: demoCommunityDetailModal.width

            StatusModalDivider { 
                bottomPadding: 8 
            }

            StatusBaseText {
                text: "A community of cat lovers, meow!"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 15
                height: 46
                color: Theme.palette.directColor1
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                anchors.rightMargin: 16
            }

            StatusModalDivider {
                topPadding: 8
                bottomPadding: 8
            }

            StatusDescriptionListItem {
                title: "Share community"
                subTitle: "https://join.status.im/u/0x04...45f19"
                tooltip.text: "Copy to clipboard"
                icon.name: "copy"
                iconButton.onClicked: tooltip.visible = !tooltip.visible
                width: parent.width
            }

            StatusModalDivider {
                topPadding: 8
                bottomPadding: 8
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                statusListItemTitle.font.pixelSize: 17
                title: "Members"
                icon.name: "group-chat"
                label: "184"
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                statusListItemTitle.font.pixelSize: 17
                title: "Notifications"
                icon.name: "notification"
                components: [
                    StatusSwitch {}
                ]
            }

            StatusModalDivider {
                topPadding: 8
                bottomPadding: 8
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                statusListItemTitle.font.pixelSize: 17
                title: "Edit community"
                icon.name: "edit"
                type: StatusListItem.Type.Secondary
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                statusListItemTitle.font.pixelSize: 17
                title: "Transfer ownership"
                icon.name: "exchange"
                type: StatusListItem.Type.Secondary
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                statusListItemTitle.font.pixelSize: 17
                title: "Leave community"
                icon.name: "arrow-right"
                icon.rotation: 180
                type: StatusListItem.Type.Secondary
            }
        }
    }

    ListModel {
        id: demoChatListItems
        ListElement {
            chatId: "0"
            name: "#status"
            chatType: StatusChatListItem.Type.PublicChat
            muted: false
            hasUnreadMessages: false
            hasMention: false
            unreadMessagesCount: 0
            iconColor: "blue"
        }
        ListElement {
            chatId: "1"
            name: "#status-desktop"
            chatType: StatusChatListItem.Type.PublicChat
            muted: false
            hasUnreadMessages: true
            iconColor: "red"
            unreadMessagesCount: 1
        }
        ListElement {
            chatId: "2"
            name: "Amazing Funny Squirrel"
            chatType: StatusChatListItem.Type.OneToOneChat
            muted: false
            hasUnreadMessages: false
            iconColor: "green"
            identicon: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
            unreadMessagesCount: 0
        }
        ListElement {
            chatId: "3"
            name: "Black Ops"
            chatType: StatusChatListItem.Type.GroupChat
            muted: false
            hasUnreadMessages: false
            iconColor: "purple"
            unreadMessagesCount: 0
        }
        ListElement {
            chatId: "4"
            name: "Spectacular Growing Otter"
            chatType: StatusChatListItem.Type.OneToOneChat
            muted: true
            hasUnreadMessages: false
            iconColor: "Orange"
            unreadMessagesCount: 0
        }
    }

    ListModel {
        id: demoCommunityChatListItems
        ListElement {
            chatId: "0"
            name: "general"
            chatType: StatusChatListItem.Type.CommunityChat
            muted: false
            hasUnreadMessages: false
            hasMention: false
            unreadMessagesCount: 0
            iconColor: "orange"
        }
        ListElement {
            chatId: "1"
            name: "random"
            chatType: StatusChatListItem.Type.CommunityChat
            muted: false
            hasUnreadMessages: false
            hasMention: false
            unreadMessagesCount: 0
            iconColor: "orange"
            categoryId: "public"
        }
        ListElement {
            chatId: "2"
            name: "watercooler"
            chatType: StatusChatListItem.Type.CommunityChat
            muted: false
            hasUnreadMessages: false
            hasMention: false
            unreadMessagesCount: 0
            iconColor: "orange"
            categoryId: "public"
        }
        ListElement {
            chatId: "3"
            name: "language-design"
            chatType: StatusChatListItem.Type.CommunityChat
            muted: false
            hasUnreadMessages: false
            hasMention: false
            unreadMessagesCount: 0
            iconColor: "orange"
            categoryId: "dev"
        }
    }

    ListModel {
        id: demoCommunityCategoryItems
        ListElement {
            categoryId: "public"
            name: "Public"
        }
        ListElement {
            categoryId: "dev"
            name: "Development"
        }
    }

    ListModel {
        id: demoProfileGeneralMenuItems

        ListElement {
            title: "My Profile"
            icon: "profile"
        }

        ListElement {
            title: "Contacts"
            icon: "contact"
        }

        ListElement {
            title: "ENS Usernames"
            icon: "username"
        }

    }

    ListModel {
        id: demoProfileSettingsMenuItems

        ListElement {
            title: "Privacy & Security"
            icon: "security"
        }

        ListElement {
            title: "Appearance"
            icon: "appearance"
        }

        ListElement {
            title: "Browser"
            icon: "browser"
        }

        ListElement {
            title: "Sounds"
            icon: "sound"
        }

        ListElement {
            title: "Language"
            icon: "language"
        }

        ListElement {
            title: "Notifications"
            icon: "notification"
        }

        ListElement {
            title: "Sync settings"
            icon: "mobile"
        }

        ListElement {
            title: "Advanced"
            icon: "settings"
        }

    }

    ListModel {
        id: demoProfileOtherMenuItems

        ListElement {
            title: "Need help?"
            icon: "help"
        }

        ListElement {
            title: "About"
            icon: "info"
        }

        ListElement {
            title: "Sign out & Quit"
            icon: "logout"
        }
    }
}
