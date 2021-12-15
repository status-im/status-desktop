import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13


import utils 1.0
import shared 1.0

import "../panels"
import "../popups"
import "../popups/community"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

Item {
    id: root
    width: 304
    height: parent.height

    // Important:
    // We're here in case of ChatSection
    // This module is set from `ChatLayout` (each `ChatLayout` has its own chatSectionModule)
    property var chatSectionModule

    property var store
    // Not Refactored Yet
    //property int chatGroupsListViewCount: channelList.model.count
    signal openProfileClicked()
    signal openAppSearch()

    Component.onCompleted: {
        appMain.openContactsPopup.connect(function(){
            Global.openPopup(contactRequestsPopup, {chatSectionModule})
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
                onClicked: root.openAppSearch()
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
                    onTriggered: Global.openPopup(privateChatPopupComponent)
                }

                StatusMenuItem {
                    //% "Start group chat"
                    text: qsTrId("start-group-chat")
                    icon.name: "group-chat"
                    onTriggered: Global.openPopup(groupChatPopupComponent)
                }

                StatusMenuItem {
                    //% "Join public chat"
                    text: qsTrId("new-public-group-chat")
                    icon.name: "public-chat"
                    onTriggered: Global.openPopup(publicChatPopupComponent)
                }

                StatusMenuItem {
                    //% "Communities"
                    text: qsTrId("communities")
                    icon.name: "communities"
                    onTriggered: Global.openPopup(communitiesPopupComponent)
                    enabled: localAccountSensitiveSettings.communitiesEnabled
                }
            }
        }
    }

    StatusContactRequestsIndicatorListItem {
        id: contactRequests

        property int nbRequests: root.store.contactRequests.count

        anchors.top: searchInputWrapper.bottom
        anchors.topMargin: visible ? Style.current.padding : 0
        anchors.horizontalCenter: parent.horizontalCenter

        visible: nbRequests > 0
        height: visible ? implicitHeight : 0

        //% "Contact requests"
        title: qsTrId("contact-requests")
        requestsCount: nbRequests

        sensor.onClicked: Global.openPopup(contactRequestsPopup)
    }

    ScrollView {
        id: chatGroupsContainer

        width: parent.width
        height: (contentHeight < (parent.height - contactRequests.height - Style.current.padding)) ? contentHeight : (parent.height - contactRequests.height - Style.current.padding)
        anchors.top: contactRequests.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: root.bottom
        contentHeight: channelList.childrenRect.height + emptyViewAndSuggestions.childrenRect.height
        anchors.horizontalCenter: parent.horizontalCenter

        leftPadding: Style.current.halfPadding
        rightPadding: Style.current.halfPadding

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        clip: true

        StatusChatList {
            id: channelList

            Connections {
                target: root.store.allContacts
                onContactChanged: {
                    // Not Refactored Yet
//                    for (var i = 0; i < channelList.chatListItems.count; i++) {
//                        if (!!channelList.statusChatListItems) {
//                            let chatItem = !!channelList.statusChatListItems.model.items ?
//                                    channelList.statusChatListItems.model.items.get(i) : null
//                            if (chatItem && chatItem.chatId === pubkey) {
//                                let profileImage = appMain.getProfileImage(pubkey)
//                                if (!!profileImage) {
//                                    chatItem.image.isIdenticon = false
//                                    chatItem.image.source = profileImage
//                                }
//                                break;
//                            }
//                        }
//                    }
                }
            }

            model: root.chatSectionModule.model
            onChatItemSelected: root.chatSectionModule.setActiveItem(id, "")
            onChatItemUnmuted: root.chatSectionModule.unmuteChat(id)

            popupMenu: ChatContextMenuView {
                id: chatContextMenuView

                openHandler: function (id) {
                    let jsonObj = root.chatSectionModule.getItemAsJson(id)
                    let obj = JSON.parse(jsonObj)
                    if (obj.error) {
                        console.error("error parsing chat item json object, id: ", id, " error: ", obj.error)
                        close()
                        return
                    }

                    isCommunityChat = root.chatSectionModule.isCommunity()
                    chatId = obj.itemId
                    chatName = obj.name
                    chatType = obj.type
                    chatMuted = obj.muted

                    // TODO
                    //currentFleet
                }

                onMuteChat: {
                    root.chatSectionModule.muteChat(id)
                }

                onUnmuteChat: {
                    root.chatSectionModule.unmuteChat(id)
                }

                onMarkAllMessagesRead: {
                    root.chatSectionModule.markAllMessagesRead(id)
                }

                onClearChatHistory: {
                    root.chatSectionModule.clearChatHistory(id)
                }
            }
        }

        EmptyViewPanel {
            id: emptyViewAndSuggestions
            visible: !localAccountSensitiveSettings.hideChannelSuggestions
            width: parent.width
            anchors.top: channelList.bottom
            anchors.topMargin: Style.current.padding
            onSuggestedMessageClicked: chatSectionModule.createPublicChat(channel)
        }
    }

    Component {
        id: publicChatPopupComponent
        PublicChatPopup {
            onJoinPublicChat: {
                chatSectionModule.createPublicChat(name)
            }
            onSuggestedMessageClicked: {
                chatSectionModule.createPublicChat(channel)
            }

            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: groupChatPopupComponent
        GroupChatPopup {
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: privateChatPopupComponent
        PrivateChatPopup {
            store: root.store
            onJoinPrivateChat: {
                chatSectionModule.createOneToOneChat(publicKey, ensName)
            }
            onClosed: {
                destroy()
            }
            onProfileClicked: {
                root.openProfileClicked();
            }
        }
    }

    Component {
        id: communitiesPopupComponent
        CommunitiesPopup {
            anchors.centerIn: parent
           communitiesList: root.store.communitiesList
            // Not Refactored Yet
//            onSetActiveCommunity: {
//                root.store.chatsModelInst.communities.setActiveCommunity(id)
//            }
//            onSetObservedCommunity: {
//                root.store.chatsModelInst.communities.setObservedCommunity(id)
//            }
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: createCommunitiesPopupComponent
        CreateCommunityPopup {
            anchors.centerIn: parent
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: importCommunitiesPopupComponent
        AccessExistingCommunityPopup {
            anchors.centerIn: parent
            // Not Refactored Yet
//            error: root.store.chatsModelInst.communities.importCommunity(communityKey, Utils.uuid())
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: communityDetailPopup
        CommunityDetailPopup {
            anchors.centerIn: parent
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: contactRequestsPopup
        ContactRequestsPopup {
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }

    // Not Refactored Yet
//    Connections {
//        target: root.store.chatsModelInst.communities
//        onImportingCommunityStateChanged: {
//            if (state !== Constants.communityImported &&
//                state !== Constants.communityImportingInProgress &&
//                state !== Constants.communityImportingError)
//            {
//                return
//            }

//            if (state === Constants.communityImported)
//            {
//                if (toastMessage.uuid !== communityImportingProcessId)
//                    return

//                toastMessage.close()

//                //% "Community imported"
//                toastMessage.title = qsTrId("community-imported")
//                toastMessage.source = ""
//                toastMessage.iconRotates = false
//                toastMessage.dissapearInMs = 4000
//            }
//            else if (state === Constants.communityImportingInProgress)
//            {
//                toastMessage.uuid = communityImportingProcessId
//                //% "Importing community is in progress"
//                toastMessage.title = qsTrId("importing-community-is-in-progress")
//                toastMessage.source = Style.svg("loading")
//                toastMessage.iconRotates = true
//                toastMessage.dissapearInMs = -1
//            }
//            else if (state === Constants.communityImportingError)
//            {
//                if (toastMessage.uuid !== communityImportingProcessId)
//                    return

//                toastMessage.close()
//                return
//            }

//            toastMessage.displayCloseButton = false
//            toastMessage.displayLink = false
//            toastMessage.iconColor = Style.current.primary
//            toastMessage.open()
//        }
//    }
}
