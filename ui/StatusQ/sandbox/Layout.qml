import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Layout 0.1

GridLayout {
    columns: 6
    columnSpacing: 5
    rowSpacing: 5

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
            tooltip.text: "Chat"
        }
    }

    StatusAppNavBar {
        navBarChatButton: StatusNavBarTabButton {
            icon.name: "chat"
            badge.value: 33
            badge.visible: true
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
                badge.border.color: Theme.palette.statusAppNavBar.backgroundColor
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
                badge.border.color: Theme.palette.statusAppNavBar.backgroundColor
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
                badge.border.color: Theme.palette.statusAppNavBar.backgroundColor
                badge.border.width: 2

                tooltip.text: "Profile"
            }
        ]
    }
}

