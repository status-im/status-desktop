import QtQuick 2.12

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "data" 1.0

StatusAppThreePanelLayout {
    id: root

    leftPanel: Item {
        anchors.fill: parent

        StatusNavigationPanelHeadline {
            id: headline
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Chat"
        }

        Item {
            id: searchInputWrapper
            anchors.top: headline.bottom
            anchors.topMargin: 16
            width: parent.width
            height: searchInput.height

            StatusBaseInput {
                id: searchInput

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: actionButton.left
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                height: 36
                topPadding: 8
                bottomPadding: 0
                placeholderText: "Search"
                icon.name: "search"
            }

            StatusRoundButton {
                id: actionButton
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 8
                width: 32
                height: 32

                type: StatusRoundButton.Type.Secondary
                icon.name: "add"
                state: "default"

                onClicked: chatContextMenu.popup(actionButton.width-chatContextMenu.width, actionButton.height + 4)
                states: [
                    State {
                        name: "default"
                        PropertyChanges {
                            target: actionButton
                            icon.rotation: 0
                            highlighted: false
                        }
                    },
                    State {
                        name: "pressed"
                        PropertyChanges {
                            target: actionButton
                            icon.rotation: 45
                            highlighted: true
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: "default"
                        to: "pressed"

                        RotationAnimation {
                            duration: 150
                            direction: RotationAnimation.Clockwise
                            easing.type: Easing.InCubic
                        }
                    },
                    Transition {
                        from: "pressed"
                        to: "default"
                        RotationAnimation {
                            duration: 150
                            direction: RotationAnimation.Counterclockwise
                            easing.type: Easing.OutCubic
                        }
                    }
                ]

                StatusPopupMenu {
                    id: chatContextMenu

                    onOpened: {
                        actionButton.state = "pressed"
                    }

                    onClosed: {
                        actionButton.state = "default"
                    }

                    StatusMenuItem {
                        text: "Start new chat"
                        icon.name: "private-chat"
                    }

                    StatusMenuItem {
                        text: "Start group chat"
                        icon.name: "group-chat"
                    }

                    StatusMenuItem {
                        text: "Join public chat"
                        icon.name: "public-chat"
                    }

                    StatusMenuItem {
                        text: "Communities"
                        icon.name: "communities"
                    }
                }
            }
        }

        Column {
            anchors.top: searchInputWrapper.bottom
            anchors.topMargin: 16
            width: parent.width
            spacing: 8

            StatusContactRequestsIndicatorListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                title: "Contact requests"
                requestsCount: 3
                sensor.onClicked: demoContactRequestsModal.open()
            }

            StatusChatList {
                anchors.horizontalCenter: parent.horizontalCenter

                chatListItems.model: Models.demoChatListItems
                selectedChatId: "0"
                onChatItemSelected: selectedChatId = id
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

    centerPanel: ListView {
        id: messageList
        anchors.fill: parent
        anchors.margins: 15
        clip: true
        model: Models.chatMessagesModel
        delegate: StatusMessage {
            id: delegate
            width: parent.width

            audioMessageInfoText: "Audio Message"
            cancelButtonText: "Cancel"
            saveButtonText: "Save"
            loadingImageText: "Loading image..."
            errorLoadingImageText: "Error loading the image"
            resendText: "Resend"
            pinnedMsgInfoText: "Pinned by"

            messageDetails: StatusMessageDetails {
                contentType: model.contentType
                messageContent: model.messageContent
                amISender: model.amIsender
                displayName: model.userName
                secondaryName: model.localName !== "" && model.ensName.startsWith("@") ? model.ensName: ""
                chatID: model.chatKey
                profileImage: StatusImageSettings {
                    width: 40
                    height: 40
                    source: model.profileImage
                    isIdenticon: model.isIdenticon
                }
                messageText: model.message
                hasMention: model.hasMention
                contactType: model.contactType
                isPinned: model.isPinned
                pinnedBy: model.pinnedBy
                hasExpired: model.hasExpired
            }
            timestamp.text: "10:00 am"
            timestamp.tooltip.text: "10:01 am"
            // reply related data
            isAReply: model.isReply
            replyDetails: StatusMessageDetails {
                amISender:  model.isReply ? model.replyAmISender : ""
                displayName:  model.isReply ? model.replySenderName: ""
                profileImage: StatusImageSettings {
                    width: 20
                    height: 20
                    source:  model.isReply ? model.replyProfileImage: ""
                    isIdenticon:  model.isReply ? model.replyIsIdenticon: ""
                }
                messageText:  model.isReply ? model.replyMessageText: ""
                contentType: model.replyContentType
                messageContent: model.replyMessageContent
            }
            quickActions: [
                StatusFlatRoundButton {
                    id: emojiBtn
                    width: 32
                    height: 32
                    icon.name: "reaction-b"
                    type: StatusFlatRoundButton.Type.Tertiary
                    tooltip.text: "Add reaction"
                },
                StatusFlatRoundButton {
                    id: replyBtn
                    width: 32
                    height: 32
                    icon.name: "reply"
                    type: StatusFlatRoundButton.Type.Tertiary
                    tooltip.text: "Reply"
                },
                StatusFlatRoundButton {
                    width: 32
                    height: 32
                    icon.name: "tiny/edit"
                    type: StatusFlatRoundButton.Type.Tertiary
                    tooltip.text: "Edit"
                    onClicked: {
                        delegate.editMode = !delegate.editMode
                    }
                },
                StatusFlatRoundButton {
                    id: otherBtn
                    width: 32
                    height: 32
                    icon.name: "more"
                    type: StatusFlatRoundButton.Type.Tertiary
                    tooltip.text: "More"
                }
            ]
        }
    }
}
