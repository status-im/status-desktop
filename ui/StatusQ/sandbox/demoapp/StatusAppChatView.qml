import QtQuick 2.12
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "data" 1.0

StatusSectionLayout {
    id: root
    property bool createChat: false

    notificationCount: 1
    onNotificationButtonClicked: { notificationCount = 0; }
    showHeader: !root.createChat

    headerContent: RowLayout {
        id: chatHeader

        signal chatInfoButtonClicked()
        signal menuButtonClicked()
        signal membersButtonClicked()
        signal searchButtonClicked()

        StatusChatInfoButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: padding
            title: "Amazing Funny Squirrel"
            subTitle: "Contact"
            asset.color: Theme.palette.miscColor7
            type: StatusChatInfoButton.Type.OneToOneChat
            pinnedMessagesCount: 1
        }

        RowLayout {
            id: actionButtons
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: padding
            spacing: 8

            StatusFlatRoundButton {
                id: menuButton
                objectName: "chatToolbarMoreOptionsButton"
                width: 32
                height: 32
                icon.name: "more"
                type: StatusFlatRoundButton.Type.Secondary

                // initializing the tooltip
                tooltip.visible: !!tooltip.text && menuButton.hovered && !contextMenu.open
                tooltip.text: qsTr("More")
                tooltip.orientation: StatusToolTip.Orientation.Bottom
                tooltip.y: parent.height + 12

                property bool showMoreMenu: false
                onClicked: {
                    menuButton.highlighted = true

                    let originalOpenHandler = contextMenu.openHandler
                    let originalCloseHandler = contextMenu.closeHandler

                    contextMenu.openHandler = function () {
                        if (!!originalOpenHandler) {
                            originalOpenHandler()
                        }
                    }

                    contextMenu.closeHandler = function () {
                        menuButton.highlighted = false
                        if (!!originalCloseHandler) {
                            originalCloseHandler()
                        }
                    }

                    contextMenu.openHandler = originalOpenHandler
                    contextMenu.popup(-contextMenu.width + menuButton.width, menuButton.height + 4)
                }
                StatusMenu {
                    id: contextMenu

                    StatusAction {
                        text: "Mute Chat"
                        icon.name: "notification"
                    }
                    StatusAction {
                        text: "Mark as Read"
                        icon.name: "checkmark-circle"
                    }
                    StatusAction {
                        text: "Clear History"
                        icon.name: "close-circle"
                    }

                    StatusMenuSeparator {}

                    StatusAction {
                        text: "Leave Chat"
                        icon.name: "arrow-left"
                        type: StatusAction.Type.Danger
                    }
                }
            }

            Rectangle {
                width: 1
                height: 24
                color: Theme.palette.directColor7
                Layout.alignment: Qt.AlignVCenter
                visible: (notificationButton.visible && menuButton.visible)
            }
        }
    }

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
            input.asset.name: "search"
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

                popupMenu: StatusMenu {

                    property string chatId

                    openHandler: function (id) {
                        chatId = id
                    }

                    StatusAction {
                        text: "View Profile"
                        icon.name: "group-chat"
                    }

                    StatusMenuSeparator {}

                    StatusAction {
                        text: "Mute chat"
                        icon.name: "notification"
                    }

                    StatusAction {
                        text: "Mark as Read"
                        icon.name: "checkmark-circle"
                    }

                    StatusAction {
                        text: "Clear history"
                        icon.name: "close-circle"
                    }

                    StatusMenuSeparator {}

                    StatusAction {
                        text: "Delete chat"
                        icon.name: "delete"
                        type: StatusAction.Type.Danger
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
}
