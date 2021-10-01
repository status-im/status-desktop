import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13


import utils 1.0
import "../../../../shared"
import "../../../../shared/status"

import "../panels"
import "../popups"
import "../popups/community"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

Item {
    id: contactsColumn
    width: 304
    height: parent.height

    property int chatGroupsListViewCount: channelList.chatListItems.count
    signal openProfileClicked()

    Component.onCompleted: {
        appMain.openContactsPopup.connect(function(){
            openPopup(contactRequestsPopup)
        })
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            //steal focus from search field
            actionButton.forceActiveFocus();
        }
    }

    StatusNavigationPanelHeadline {
        id: headline
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        //% "Chat"
        text: qsTrId("chat")
    }

    Item {
        id: searchInputWrapper
        anchors.top: headline.bottom
        anchors.topMargin: 16
        width: parent.width
        height: searchInput.height

        Item {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: actionButton.left
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            implicitHeight: searchInput.height
            implicitWidth: searchInput.width

            StatusBaseInput {
                id: searchInput
                implicitHeight: 36
                width: parent.width
                topPadding: 9
                //% "Search"
                placeholderText: qsTrId("search")
                icon.name: "search"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: searchPopup.open()
            }
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

            onClicked: {
                chatContextMenu.opened ?
                    chatContextMenu.close() :
                    chatContextMenu.popup(actionButton.width-chatContextMenu.width, actionButton.height + 4)
            }
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
                closePolicy: Popup.CloseOnReleaseOutsideParent | Popup.CloseOnEscape

                onOpened: {
                    actionButton.state = "pressed"
                }

                onClosed: {
                    actionButton.state = "default"
                }

                StatusMenuItem {
                    //% "Start new chat"
                    text: qsTrId("start-new-chat")
                    icon.name: "private-chat"
                    onTriggered: openPopup(privateChatPopupComponent)
                }

                StatusMenuItem {
                    //% "Start group chat"
                    text: qsTrId("start-group-chat")
                    icon.name: "group-chat"
                    onTriggered: openPopup(groupChatPopupComponent)
                }

                StatusMenuItem {
                    //% "Join public chat"
                    text: qsTrId("new-public-group-chat")
                    icon.name: "public-chat"
                    onTriggered: openPopup(publicChatPopupComponent)
                }

                StatusMenuItem {
                    //% "Communities"
                    text: qsTrId("communities")
                    icon.name: "communities"
                    onTriggered: openPopup(communitiesPopupComponent)
                    enabled: appSettings.communitiesEnabled
                }
            }
        }
    }

    StatusContactRequestsIndicatorListItem {
        id: contactRequests

        property int nbRequests: profileModel.contacts.contactRequests.count

        anchors.top: searchInputWrapper.bottom
        anchors.topMargin: visible ? Style.current.padding : 0
        anchors.horizontalCenter: parent.horizontalCenter

        visible: nbRequests > 0
        height: visible ? implicitHeight : 0

        //% "Contact requests"
        title: qsTrId("contact-requests")
        requestsCount: nbRequests

        sensor.onClicked: openPopup(contactRequestsPopup)
    }

    ScrollView {
        id: chatGroupsContainer

        width: parent.width
        height: (contentHeight < (parent.height - contactRequests.height - Style.current.padding)) ? contentHeight : (parent.height - contactRequests.height - Style.current.padding)
        anchors.top: contactRequests.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: contactsColumn.bottom
        contentHeight: channelList.childrenRect.height + emptyViewAndSuggestions.childrenRect.height
        anchors.horizontalCenter: parent.horizontalCenter

        leftPadding: Style.current.halfPadding
        rightPadding: Style.current.halfPadding

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        clip: true

        StatusChatList {
            id: channelList

            chatNameFn: function (chatItem) {
                return chatItem.chatType !== Constants.chatTypePublic ?
                            Emoji.parse(Utils.removeStatusEns(Utils.filterXSS(chatItem.name))) :
                            Utils.filterXSS(chatItem.name)
            }

            profileImageFn: function (id) {
                return appMain.getProfileImage(id)
            }

            Connections {
                target: profileModel.contacts.list
                onContactChanged: {
                    for (var i = 0; i < channelList.chatListItems.count; i++) {
                        let chatItem = channelList.statusChatListItems.model.itemAt(i);
                        if (chatItem.chatId === pubkey) {
                            let profileImage = appMain.getProfileImage(pubkey)
                            if (!!profileImage) {
                                chatItem.image.isIdenticon = false
                                chatItem.image.source = profileImage
                            }
                            break;
                        }
                    }
                }
            }

            chatListItems.model: chatsModel.channelView.chats
            selectedChatId: chatsModel.channelView.activeChannel.id

            onChatItemSelected: chatsModel.channelView.setActiveChannel(id)
            onChatItemUnmuted: chatsModel.channelView.unmuteChatItem(id)

            popupMenu: ChatContextMenuView {
                openHandler: function (id) {
                    chatItem = chatsModel.channelView.getChatItemById(id)
                }
            }
        }

        EmptyViewPanel {
            id: emptyViewAndSuggestions
            visible: !appSettings.hideChannelSuggestions
            width: parent.width
            anchors.top: channelList.bottom
            anchors.topMargin: Style.current.padding
        }
    }

    Component {
        id: publicChatPopupComponent
        PublicChatPopup {
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: groupChatPopupComponent
        GroupChatPopup {
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: privateChatPopupComponent
        PrivateChatPopup {
            onClosed: {
                destroy()
            }
            onProfileClicked: {
                contactsColumn.openProfileClicked();
            }
        }
    }

    Component {
        id: communitiesPopupComponent
        CommunitiesPopup {
            anchors.centerIn: parent
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: createCommunitiesPopupComponent
        CreateCommunityPopup {
            anchors.centerIn: parent
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: importCommunitiesPopupComponent
        AccessExistingCommunityPopup {
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: communityDetailPopup
        CommunityDetailPopup {
            anchors.centerIn: parent
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: contactRequestsPopup
        ContactRequestsPopup {
            onClosed: {
                destroy()
            }
        }
    }

    Connections {
        target: chatsModel.communities
        onImportingCommunityStateChanged: {
            if (state !== Constants.communityImported &&
                state !== Constants.communityImportingInProgress &&
                state !== Constants.communityImportingError)
            {
                return
            }

            if (state === Constants.communityImported)
            {
                if (toastMessage.uuid !== communityImportingProcessId)
                    return

                toastMessage.close()

                //% "Community imported"
                toastMessage.title = qsTrId("community-imported")
                toastMessage.source = ""
                toastMessage.iconRotates = false
                toastMessage.dissapearInMs = 4000
            }
            else if (state === Constants.communityImportingInProgress)
            {
                toastMessage.uuid = communityImportingProcessId
                //% "Importing community is in progress"
                toastMessage.title = qsTrId("importing-community-is-in-progress")
                toastMessage.source = Style.svg("loading")
                toastMessage.iconRotates = true
                toastMessage.dissapearInMs = -1
            }
            else if (state === Constants.communityImportingError)
            {
                if (toastMessage.uuid !== communityImportingProcessId)
                    return

                toastMessage.close()
                return
            }

            toastMessage.displayCloseButton = false
            toastMessage.displayLink = false
            toastMessage.iconColor = Style.current.primary
            toastMessage.open()
        }
    }
}
