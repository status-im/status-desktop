import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1

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
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.name
                tooltip.text: model.tooltipText
                icon.color: Theme.palette.miscColor6
                icon.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
                checked: appView.sourceComponent == statusAppCommunityView
                onClicked: {
                    appView.sourceComponent = statusAppCommunityView
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

                Column {
                    anchors.top: parent.top
                    anchors.topMargin: 64
                    anchors.horizontalCenter: parent.horizontalCenter

                    spacing: 4

                    StatusChatListItem {
                        name: "#status"
                        type: StatusChatListItem.Type.PublicChat
                    }

                    StatusChatListItem {
                        name: "#status-desktop"
                        type: StatusChatListItem.Type.PublicChat
                        hasUnreadMessages: true
                        badge.value: 1
                    }

                    StatusChatListItem {
                        name: "Amazing Funny Squirrel"
                        type: StatusChatListItem.Type.OneToOneChat
                        selected: true
                    }

                    StatusChatListItem {
                        name: "Black Ops"
                        type: StatusChatListItem.Type.GroupChat
                    }

                    StatusChatListItem {
                        name: "Spectacular Growling Otter"
                        type: StatusChatListItem.Type.OneToOneChat
                        muted: true
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

                    onMenuButtonClicked: notificationCount += 1
                    onNotificationButtonClicked: notificationCount = 0
                }
            }
        }
    }

    Component {
        id: statusAppCommunityView

        StatusAppTwoPanelLayout {

            leftPanel: Item {
                anchors.fill: parent

                Column {
                    anchors.top: parent.top
                    anchors.topMargin: 64
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    StatusChatListItem {
                        name: "general"
                        type: StatusChatListItem.Type.CommunityChat
                        selected: true
                    }

                    StatusChatListItem {
                        name: "random"
                        type: StatusChatListItem.Type.CommunityChat
                    }

                    StatusChatListItem {
                        name: "watercooler"
                        type: StatusChatListItem.Type.CommunityChat
                        muted: true
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
}
