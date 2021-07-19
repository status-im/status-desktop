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

    StatusNavigationPanelHeadline {
        id: headline
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Chat")
    }

    SearchBox {
        id: searchBox
        anchors.top: headline.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: addChat.left
        anchors.rightMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
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

        title: qsTr("Contact requests")
        requestsCount: nbRequests

        sensor.onClicked: openPopup(contactRequestsPopup)
    }

    ScrollView {
        id: chatGroupsContainer

        anchors.top: contactRequests.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width

        leftPadding: Style.current.halfPadding
        rightPadding: Style.current.halfPadding

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        contentHeight: channelList.height + 2 * Style.current.padding + emptyViewAndSuggestions.height + emptyViewAndSuggestions.anchors.topMargin
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
                text: qsTr("No search results")
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
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
