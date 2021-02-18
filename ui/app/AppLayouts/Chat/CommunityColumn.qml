import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "./ContactsColumn"
import "./CommunityComponents"

Item {
    // TODO unhardcode
    property int chatGroupsListViewCount: channelList.channelListCount

    id: root
    Layout.fillHeight: true

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
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding

        StatusIconButton {
            id: backArrow
            icon.name: "arrow-right"
            iconRotation: 180
            iconColor: Style.current.inputColor
            anchors.left: parent.left
            anchors.leftMargin: Style.current.bigPadding
            anchors.verticalCenter: parent.verticalCenter
            onClicked: chatsModel.activeCommunity.active = false
        }

        CommunityHeaderButton {
            id: communityHeaderButton
            anchors.left: backArrow.right
            anchors.top: parent.top
            anchors.topMargin: -4
        }

        StatusIconButton {
            id: optionsBtn
            icon.name: "dots-icon"
            iconColor: Style.current.inputColor
            anchors.right: parent.right
            anchors.rightMargin: Style.current.bigPadding
            anchors.verticalCenter: parent.verticalCenter
            onClicked: optionsMenu.open()
        }

        PopupMenu {
            id: optionsMenu
            x: optionsBtn.x + optionsBtn.width / 2 - optionsMenu.width / 2
            y: optionsBtn.height

            Action {
                enabled: chatsModel.activeCommunity.admin
                //% "Create channel"
                text: qsTrId("create-channel")
                icon.source: "../../img/hash.svg"
                icon.width: 20
                icon.height: 20
                onTriggered: openPopup(createChannelPopup, {communityId: chatsModel.activeCommunity.id})
            }

            Action {
                //% "Leave community"
                text: qsTrId("leave-community")
                icon.source: "../../img/delete.svg"
                icon.color: Style.current.red
                icon.width: 20
                icon.height: 20
                onTriggered: chatsModel.leaveCurrentCommunity()
            }
        }
    }


    ScrollView {
        id: chatGroupsContainer
        anchors.top: communityHeader.bottom
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
            channelModel: chatsModel.activeCommunity.chats
        }

        CommunityWelcomeBanner {
            id: emptyViewAndSuggestions
            visible: chatsModel.activeCommunity.admin
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
