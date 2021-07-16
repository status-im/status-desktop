import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "./components"
import "./ContactsColumn"
import "./CommunityComponents"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

Item {
    property int chatGroupsListViewCount: channelList.chatListItems.count
    property alias searchStr: searchBox.text

    id: contactsColumn

    Layout.fillHeight: true
    width: 304

    MouseArea {
        anchors.fill: parent
        onClicked: {
            //steal focus from search field
            addChat.forceActiveFocus();
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

    SearchBox {
        id: searchBox
        anchors.top: headline.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: addChat.left
        anchors.rightMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        Keys.onEscapePressed: {
            addChat.forceActiveFocus();
        }
    }

    AddChat {
        id: addChat
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.top: headline.bottom
        anchors.topMargin: Style.current.padding
    }

    StatusContactRequestsIndicatorListItem {
        id: contactRequests

        property int nbRequests: profileModel.contacts.contactRequests.count

        anchors.top: searchBox.bottom
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
        contentHeight: channelList.height + 2 * Style.current.padding + emptyViewAndSuggestions.height + emptyViewAndSuggestions.anchors.topMargin
        anchors.horizontalCenter: parent.horizontalCenter


        leftPadding: Style.current.halfPadding
        rightPadding: Style.current.halfPadding

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        clip: true

        Item {
            id: noSearchResults
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            visible: !!!channelList.height && contactsColumn.searchStr !== ""
            height: visible ? 300 : 0

            StatusBaseText {
                font.pixelSize: 15
                color: Theme.palette.directColor5
                anchors.centerIn: parent
                //% "No search results"
                text: qsTrId("no-search-results")
            }
        }

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

            filterFn: function (chatListItem) {
                return !!!contactsColumn.searchStr || chatListItem.name.toLowerCase().includes(contactsColumn.searchStr.toLowerCase())
            }

            Connections {
                target: profileModel.contacts.list
                onContactChanged: {
                    for (var i = 0; i < channelList.chatListItems.count; i++) {
                        let chatItem = channelList.chatListItems.itemAt(i);
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

            popupMenu: ChatContextMenu {
                openHandler: function (id) {
                    chatItem = chatsModel.channelView.getChatItemById(id)
                }
            }
        }

        EmptyView {
            id: emptyViewAndSuggestions
            width: parent.width
            visible: !appSettings.hideChannelSuggestions && !noSearchResults.visible
            anchors.top: noSearchResults.visible ? noSearchResults.bottom : channelList.bottom
            anchors.topMargin: 32
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
        }
    }

    Component {
        id: communitiesPopupComponent
        CommunitiesPopup {
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: createCommunitiesPopupComponent
        CreateCommunityPopup {
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
                toastMessage.source = "../../img/loading.svg"
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
