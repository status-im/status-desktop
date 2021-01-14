import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import "../../../imports"
import "../../../shared"
import "./components"
import "./ContactsColumn"
import "./CommunityComponents"

Item {
    property alias chatGroupsListViewCount: channelList.channelListCount
    property alias searchStr: searchBox.text

    id: contactsColumn
    Layout.fillHeight: true

    StyledText {
        id: title
        //% "Chat"
        text: qsTrId("chat")
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Bold
        font.pixelSize: 17
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
        ImportCommunityPopup {
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

    SearchBox {
        id: searchBox
        anchors.top: title.bottom
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
        anchors.top: title.bottom
        anchors.topMargin: Style.current.padding
    }

    ScrollView {
        id: chatGroupsContainer
        anchors.top: searchBox.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        leftPadding: Style.current.halfPadding
        rightPadding: Style.current.halfPadding
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentHeight: communitiesListLoader.height + channelList.height + 2 * Style.current.padding + emptyViewAndSuggestions.height
        clip: true

        Loader {
            id: communitiesListLoader
            active: appSettings.communitiesEnabled
            width: parent.width
            height: {
                if (item && active) {
                    return item.height
                }

                return 0
            }
            sourceComponent: Component {
                CommunityList {
                    id: communityList
                    visible: appSettings.communitiesEnabled
                    searchStr: contactsColumn.searchStr.toLowerCase()
                }
            }
        }

        Separator {
            id: communitySep
            visible: communitiesListLoader.active && communitiesListLoader.height > 0
            anchors.top: communitiesListLoader.bottom
            anchors.topMargin: visible ? Style.current.halfPadding : 0
        }

        ChannelList {
            id: channelList
            anchors.top: communitySep.bottom
            anchors.topMargin: Style.current.halfPadding
            searchStr: contactsColumn.searchStr.toLowerCase()
            channelModel: chatsModel.chats
        }

        EmptyView {
            id: emptyViewAndSuggestions
            width: parent.width
            anchors.top: channelList.bottom
            anchors.topMargin: Style.current.smallPadding
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
