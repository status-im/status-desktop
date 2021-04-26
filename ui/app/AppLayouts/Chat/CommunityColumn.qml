import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13

import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "./ContactsColumn"
import "./CommunityComponents"

Rectangle {
    // TODO unhardcode
    property int chatGroupsListViewCount: channelList.channelListCount

    id: root
    Layout.fillHeight: true
    color: Style.current.secondaryMenuBackground

    Component {
        id: createChannelPopup
        CreateChannelPopup {
            onClosed: {
                destroy()
            }
        }
    }

    Item {
        id: communityHeader
        width: parent.width
        height: communityHeaderButton.height
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding

        CommunityHeaderButton {
            id: communityHeaderButton
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: -4
        }

        StatusRoundButton {
            id: optionsBtn
            pressedIconRotation: 45
            icon.name: "plusSign"
            size: "medium"
            type: "secondary"
            width: 36 * scaleAction.factor
            height: 36 * scaleAction.factor
            anchors.right: parent.right
            anchors.rightMargin: Style.current.bigPadding
            anchors.top: parent.top
            anchors.topMargin: 8
            visible: chatsModel.communities.activeCommunity.admin

            onClicked: {
                optionsBtn.state = "pressed"
                let x = optionsBtn.iconX + optionsBtn.icon.width / 2 - optionsMenu.width / 2
                optionsMenu.popup(x, optionsBtn.icon.height + 14)
            }

            PopupMenu {
                id: optionsMenu
                x: optionsBtn.x + optionsBtn.width / 2 - optionsMenu.width / 2
                y: optionsBtn.height

                Action {
                    enabled: chatsModel.communities.activeCommunity.admin
                    //% "Create channel"
                    text: qsTrId("create-channel")
                    icon.source: "../../img/hash.svg"
                    icon.width: 20 * scaleAction.factor
                    icon.height: 20 * scaleAction.factor
                    onTriggered: openPopup(createChannelPopup, {communityId: chatsModel.communities.activeCommunity.id})
                }

                Action {
                    text: qsTr("Invite People")
                    enabled: chatsModel.communities.activeCommunity.canManageUsers
                    icon.source: "../../img/export.svg"
                    icon.width: 20 * scaleAction.factor
                    icon.height: 20 * scaleAction.factor
                    onTriggered: openPopup(inviteFriendsToCommunityPopup, {communityId: chatsModel.communities.activeCommunity.id})
                }

                onAboutToHide: {
                    optionsBtn.state = "default"
                }
            }
        }
    }

    Loader {
        id: membershipRequestsLoader
        width: parent.width
        active: chatsModel.communities.activeCommunity.admin
        anchors.top: communityHeader.bottom
        anchors.topMargin: item && item.visible ? Style.current.halfPadding : 0

        sourceComponent: Component {
            MembershipRequestsButton {}
        }
    }

    MembershipRequestsPopup {
        id: membershipRequestPopup
    }

    ScrollView {
        id: chatGroupsContainer
        anchors.top: membershipRequestsLoader.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        leftPadding: Style.current.halfPadding
        rightPadding: Style.current.halfPadding
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentHeight: channelList.height + emptyViewAndSuggestions.height + 2 * Style.current.padding
        clip: true

        ChannelList {
            id: channelList
            searchStr: ""
            channelModel: chatsModel.communities.activeCommunity.chats
        }

        CommunityWelcomeBanner {
            id: emptyViewAndSuggestions
            visible: !appSettings.hiddenCommunityWelcomeBanners.includes(chatsModel.communities.activeCommunity.id) && chatsModel.communities.activeCommunity.admin
            width: parent.width
            anchors.top: channelList.bottom
            anchors.topMargin: Style.current.padding
        }

        CommunityProfilePopup {
            id: communityProfilePopup
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
