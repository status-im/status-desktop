import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "./ContactsColumn"
import "./ContactsColumn/CommunityComponents"

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
        height: communityImage.height
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

        RoundedImage {
            id: communityImage
            width: 40
            height: 40
            // TODO get the real image once it's available
            source: "../../img/ens-header-dark@2x.png"
            anchors.left: backArrow.right
            anchors.leftMargin: Style.current.smallPadding
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            id: communityName
            text: chatsModel.activeCommunity.name
            anchors.left: communityImage.right
            anchors.leftMargin: Style.current.halfPadding
            font.pixelSize: 15
            font.weight: Font.Medium
        }

        StyledText {
            id: communityNbMember
            // TOD get real numbers
            text: qsTr("%1 members").arg(12)
            anchors.left: communityName.left
            anchors.bottom: parent.bottom
            font.pixelSize: 12
            font.weight: Font.Thin
            color: Style.current.secondaryText
        }

        StatusIconButton {
            id: optionsBtn
            icon.name: "dots-icon"
            iconColor: Style.current.inputColor
            anchors.right: parent.right
            anchors.rightMargin: Style.current.bigPadding
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                optionsMenu.open()
            }
        }

        PopupMenu {
            id: optionsMenu
            x: optionsBtn.x + optionsBtn.width / 2 - optionsMenu.width / 2
            y: optionsBtn.height

            Action {
                enabled: chatsModel.activeCommunity.admin
                text: qsTrId("Create channel")
                icon.source: "../../img/hash.svg"
                icon.width: 20
                icon.height: 20
                onTriggered: openPopup(createChannelPopup, {communityId: chatsModel.activeCommunity.id})
            }

            Action {
                text: qsTrId("Leave community")
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
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
