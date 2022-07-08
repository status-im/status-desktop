import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../helpers/channelList.js" as ChannelJSON

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1 as StatusQControls

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0

import utils 1.0

Rectangle {
    id: emptyView
    Layout.fillHeight: true
    Layout.fillWidth: true

    property var rootStore

    signal suggestedMessageClicked(string channel)

    height: suggestionContainer.height + inviteFriendsContainer.height + Style.current.padding * 2
    border.color: Style.current.secondaryMenuBorder
    radius: 16
    color: Style.current.transparent

    anchors.right: parent.right
    anchors.left: parent.left
    anchors.leftMargin: Style.current.padding
    anchors.rightMargin: Style.current.padding

    Item {
        id: inviteFriendsContainer
        height: visible ? 190 : 0
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0

        SVGImage {
            anchors.top: parent.top
            anchors.topMargin: -6
            anchors.horizontalCenter: parent.horizontalCenter
            source: Style.svg("chatEmptyHeader")
            width: 66
            height: 50
        }


        StatusQControls.StatusFlatRoundButton {
            id: closeImg
            implicitWidth: 32
            implicitHeight: 32
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            icon.height: 20
            icon.width: 20
            icon.name: "close-circle"
            type: StatusQControls.StatusFlatRoundButton.Type.Tertiary
            onClicked: {
                localAccountSensitiveSettings.hideChannelSuggestions = true
            }
        }

        StatusBaseText {
            id: chatAndTransactText
            text: qsTr("Chat and transact privately with your friends")
            anchors.top: parent.top
            anchors.topMargin: 56
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 15
            wrapMode: Text.WordWrap
            anchors.right: parent.right
            anchors.rightMargin: Style.current.xlPadding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.xlPadding
            color: Theme.palette.directColor1
        }

        StatusQControls.StatusButton {
            text: qsTr("Invite friends")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.current.xlPadding
            onClicked: {
                inviteFriendsPopup.open()
            }
        }

        InviteFriendsPopup {
            id: inviteFriendsPopup
            rootStore: emptyView.rootStore
        }
    }

    Separator {
        anchors.topMargin: 0
        anchors.top: inviteFriendsContainer.bottom
        color: Style.current.border
    }

    Item {
        id: suggestionContainer
        anchors.top: inviteFriendsContainer.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding

        height: {
            if (!visible) return 0
            var totalHeight = 0
            for (let i = 0; i < sectionRepeater.count; i++) {
                totalHeight += sectionRepeater.itemAt(i).height + Style.current.padding
            }
            return suggestionsText.height + totalHeight + Style.current.smallPadding
        }

        StatusBaseText {
            id: suggestionsText
            width: parent.width
            text: qsTr("Follow your interests in one of the many Public Chats.")
            anchors.top: parent.top
            anchors.topMargin: Style.current.xlPadding
            font.pointSize: 15
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.FixedSize
            renderType: Text.QtRendering
            anchors.right: parent.right
            anchors.rightMargin: Style.current.xlPadding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.xlPadding
            color: Theme.palette.directColor1
        }

        Item {
            anchors.top: suggestionsText.bottom
            anchors.topMargin: Style.current.smallPadding
            width: parent.width

            SuggestedChannelsPanel {
                id: sectionRepeater
                onSuggestedMessageClicked: emptyView.suggestedMessageClicked(channel)
            }
        }
    }
}
