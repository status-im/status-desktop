import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "./components"
import "./ContactsColumn"

Item {
    // TODO unhardcode
    property int chatGroupsListViewCount: 2

    id: root
    Layout.fillHeight: true

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
        contentHeight: channelList.height + Style.current.padding + emptyViewAndSuggestions.height
        clip: true

        ChannelList {
            id: channelList
            searchStr: ""
            channelModel: chatsModel.activeCommunity.chats
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
