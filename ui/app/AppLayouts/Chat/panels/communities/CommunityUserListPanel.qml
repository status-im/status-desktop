import QtQuick 2.13
import Qt.labs.platform 1.1
import QtQuick.Controls 2.13
import QtQuick.Window 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.13
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../../shared"
import "../../../../../shared/status"

import utils 1.0

import "../../controls"

import StatusQ.Core.Theme 0.1

Item {
    id: root
    anchors.fill: parent
    property var userList
    property var currentTime
    property var contactsList
    property string profilePubKey
    property var messageContextMenu
    property QtObject community: chatsModel.communities.activeCommunity

    StyledText {
        id: titleText
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        opacity: (root.width > 58) ? 1.0 : 0.0
        visible: (opacity > 0.1)
        font.pixelSize: Style.current.primaryTextFontSize
        font.bold: true
        //% "Members"
        text: qsTrId("members-label")
    }

    ListView {
        id: userListView
        clip: true
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
        anchors {
            top: titleText.bottom
            topMargin: Style.current.padding
            left: parent.left
            right: parent.right
            rightMargin: Style.current.halfPadding
            bottom: parent.bottom
            bottomMargin: Style.current.bigPadding
        }
        boundsBehavior: Flickable.StopAtBounds
        model: userListDelegate
        section.property: "online"
        section.delegate: (root.width > 58) ? sectionDelegateComponent : null
        Component {
            id: sectionDelegateComponent
            Item {
                width: parent.width
                height: 24
                StyledText {
                    anchors.fill: parent
                    anchors.leftMargin: Style.current.padding
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Style.current.additionalTextSize
                    color: Theme.palette.baseColor1
                    text: section === 'true' ? qsTr("Online") : qsTr("Offline")
                }
            }
        }
    }
    
    DelegateModelGeneralized {
        id: userListDelegate
        lessThan: [
            function(left, right) {
                return left.sortKey.localeCompare(right.sortKey) < 0
            }
        ]
        model: community.members
        delegate: UserDelegate {
            publicKey: model.pubKey
            name: model.userName
            identicon: model.identicon
            lastSeen: model.lastSeen
            statusType: model.statusType
            currentTime: root.currentTime
            isOnline: model.online
            contactsList: root.contactsList
            profilePubKey: root.profilePubKey
            messageContextMenu: root.messageContextMenu
        }
    }
}
