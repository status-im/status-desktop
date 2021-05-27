import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1

Column {
    spacing: 5

    StatusChatToolBar {
        chatInfoButton.title: "Some contact"        
        chatInfoButton.subTitle: "Contact"
        chatInfoButton.icon.color: Theme.palette.miscColor7
        chatInfoButton.type: StatusChatInfoButton.Type.OneToOneChat
    }

    StatusChatToolBar {
        chatInfoButton.title: "Some contact"        
        chatInfoButton.subTitle: "Contact"
        chatInfoButton.icon.color: Theme.palette.miscColor7
        chatInfoButton.type: StatusChatInfoButton.Type.PublicChat
        chatInfoButton.pinnedMessagesCount: 1
        chatInfoButton.muted: true
    }

    StatusChatToolBar {
        chatInfoButton.title: "Some contact"        
        chatInfoButton.subTitle: "Contact"
        chatInfoButton.icon.color: Theme.palette.miscColor7
        chatInfoButton.type: StatusChatInfoButton.Type.OneToOneChat
        chatInfoButton.pinnedMessagesCount: 1
        notificationCount: 1
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

        StatusAppNavBar {
            navBarChatButton: StatusNavBarTabButton {
                icon.name: "chat"
                badge.value: 33
                badge.visible: true
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                tooltip.text: "Chat"
            }
        }

        StatusAppNavBar {
            navBarChatButton: StatusNavBarTabButton {
                icon.name: "chat"
                badge.value: 33
                badge.visible: true
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                tooltip.text: "Chat"
            }

            navBarCommunityTabButtons.model: ListModel {
                id: buttons
                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }
            }

            navBarCommunityTabButtons.delegate: StatusNavBarTabButton {
                name: model.name
                tooltip.text: model.name
                anchors.horizontalCenter: parent.horizontalCenter
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
                    icon.name: "profile"
                    badge.visible: true
                    badge.anchors.rightMargin: 4
                    badge.anchors.topMargin: 5
                    badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                    badge.border.width: 2

                    tooltip.text: "Profile"
                }
            ]
        }

        StatusAppNavBar {
            navBarChatButton: StatusNavBarTabButton {
                icon.name: "chat"
                badge.value: 33
                badge.visible: true
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                tooltip.text: "Chat"
            }

            navBarCommunityTabButtons.model: ListModel {
                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }
            }

            navBarCommunityTabButtons.delegate: StatusNavBarTabButton {
                name: model.name
                tooltip.text: model.name
                anchors.horizontalCenter: parent.horizontalCenter
            }

            navBarTabButtons: [
                StatusNavBarTabButton {
                    icon.name: "wallet"
                    tooltip.text: "Wallet"
                },
                StatusNavBarTabButton {
                    icon.name: "browser"
                    tooltip.text: "Browser"
                }
            ]
        }

        StatusAppNavBar {
            navBarChatButton: StatusNavBarTabButton {
                icon.name: "chat"
                badge.value: 33
                badge.visible: true
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                tooltip.text: "Chat"
            }

            navBarCommunityTabButtons.model: ListModel {
                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }

                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }

                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }
                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }
            }

            navBarCommunityTabButtons.delegate: StatusNavBarTabButton {
                name: model.name
                tooltip.text: model.name
                anchors.horizontalCenter: parent.horizontalCenter
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
                    icon.name: "profile"
                    badge.visible: true
                    badge.anchors.rightMargin: 4
                    badge.anchors.topMargin: 5
                    badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                    badge.border.width: 2

                    tooltip.text: "Profile"
                }
            ]
        }

        StatusAppNavBar {
            id: test
            navBarChatButton: StatusNavBarTabButton {
                icon.name: "chat"
                badge.value: 33
                badge.visible: true
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                tooltip.text: "Chat"
            }

            navBarCommunityTabButtons.model: ListModel {
                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }

                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }
                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }
                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }
                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }
                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }
                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }
                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }
                ListElement {
                    name: "Test community"
                    tooltipText: "Test Community"
                }
            }

            navBarCommunityTabButtons.delegate: StatusNavBarTabButton {
                name: model.name
                tooltip.text: model.name
                anchors.horizontalCenter: parent.horizontalCenter
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
                    icon.name: "profile"
                    badge.visible: true
                    badge.anchors.rightMargin: 4
                    badge.anchors.topMargin: 5
                    badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                    badge.border.width: 2

                    tooltip.text: "Profile"
                }
            ]
        }
    }
}

