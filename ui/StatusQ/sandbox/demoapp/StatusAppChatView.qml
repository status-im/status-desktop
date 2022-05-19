import QtQuick 2.12
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "data" 1.0

StatusAppThreePanelLayout {
    id: root
    property bool createChat: false

    leftPanel: Item {
        anchors.fill: parent

        StatusNavigationPanelHeadline {
            id: headline
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Chat"
        }

        RowLayout {
            id: searchInputWrapper
            width: 288
            height: searchInput.height
            anchors.top: headline.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter

            StatusBaseInput {
                id: searchInput
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                implicitHeight: 36
                topPadding: 8
                bottomPadding: 8
                placeholderText: "Search"
                icon.name: "search"
            }

            StatusIconTabButton {
                icon.name: "public-chat"
            }

            StatusIconTabButton {
                icon.name: "edit"
                onClicked: {
                    root.createChat = !root.createChat;
                }
            }
        }

        Column {
            anchors.top: searchInputWrapper.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            StatusContactRequestsIndicatorListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                title: "Contact requests"
                requestsCount: 3
                sensor.onClicked: demoContactRequestsModal.open()
            }

            StatusChatList {
                model: Models.demoChatListItems
                highlightItem: !root.createChat
                onChatItemUnmuted: {
                    for (var i = 0; i < Models.demoChatListItems.count; i++) {
                        let item = Models.demoChatListItems.get(i);
                        if (item.chatId === id) {
                            Models.demoChatListItems.setProperty(i, "muted", false)
                        }
                    }
                }

                popupMenu: StatusPopupMenu {

                    property string chatId

                    openHandler: function (id) {
                        chatId = id
                    }

                    StatusMenuItem {
                        text: "View Profile"
                        icon.name: "group-chat"
                    }

                    StatusMenuSeparator {}

                    StatusMenuItem {
                        text: "Mute chat"
                        icon.name: "notification"
                    }

                    StatusMenuItem {
                        text: "Mark as Read"
                        icon.name: "checkmark-circle"
                    }

                    StatusMenuItem {
                        text: "Clear history"
                        icon.name: "close-circle"
                    }

                    StatusMenuSeparator {}

                    StatusMenuItem {
                        text: "Delete chat"
                        icon.name: "delete"
                        type: StatusMenuItem.Type.Danger
                    }
                }
            }
        }
    }

    centerPanel: Loader {
        anchors.fill: parent
        sourceComponent: root.createChat ? createChatView : chatChannelView
        Component {
            id: createChatView
            CreateChatView {
                contactsModel: Models.membersListModel
            }
        }

        Component {
            id: chatChannelView
            ChatChannelView {
                model: Models.chatMessagesModel
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

            searchButton.visible: false
            membersButton.visible: false
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
