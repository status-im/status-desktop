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
        anchors.margins: 16
        RowLayout {
            id: searchInputWrapper
            width: parent.width

            StatusNavigationPanelHeadline {
                id: headline
                Layout.alignment: Qt.AlignVCenter
                text: "Chat"
            }

            Item {
                Layout.fillWidth: true
            }


            StatusRoundButton {
                Layout.alignment: Qt.AlignVCenter
                icon.name: "public-chat"
                icon.color: Theme.palette.directColor1
                icon.height: editBtn.icon.height
                icon.width: editBtn.icon.width
                implicitWidth: editBtn.implicitWidth
                implicitHeight: editBtn.implicitHeight
                type: StatusRoundButton.Type.Tertiary
                StatusToolTip {
                    text: qsTr("Join public chats")
                    visible: parent.hovered
                    orientation: StatusToolTip.Orientation.Bottom
                    y: parent.height + 12
                }
            }

            StatusIconTabButton {
                id: editBtn
                icon.name: "edit"
                icon.color: Theme.palette.directColor1
                checked: root.createChat
                highlighted: checked
                onClicked: {
                    root.createChat = !root.createChat;
                }
                StatusToolTip {
                    text: qsTr("Start chat")
                    visible: parent.hovered
                    orientation: StatusToolTip.Orientation.Bottom
                    y: parent.height + 12
                }
            }
        }

        StatusInput {
            id: searchInput
            anchors.top: searchInputWrapper.bottom
            anchors.topMargin: 16
            width: parent.width
            maximumHeight: 36
            topPadding: 8
            bottomPadding: 8
            placeholderText: "Search"
            input.icon.name: "search"
        }

        Column {
            width: parent.width
            anchors.top: searchInput.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            StatusContactRequestsIndicatorListItem {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                title: "Contact requests"
                requestsCount: 3
                onClicked: demoContactRequestsModal.open()
            }

            StatusChatList {
                width: parent.width
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
            width: parent.width
            toolbarComponent: statusChatInfoButton
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
                    icon.name: "arrow-left"
                    type: StatusMenuItem.Type.Danger
                }
            }

            Component {
                id: statusChatInfoButton

                StatusChatInfoButton {
                   width: Math.min(implicitWidth, parent.width)
                   title: "Amazing Funny Squirrel"
                   subTitle: "Contact"
                   icon.color: Theme.palette.miscColor7
                   type: StatusChatInfoButton.Type.OneToOneChat
                   pinnedMessagesCount: 1
                }
            }
        }
    }
}
