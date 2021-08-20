import QtQuick 2.13
import Qt.labs.platform 1.1
import QtQuick.Controls 2.13
import QtQuick.Window 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.13
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "../components"
import "../ChatColumn/MessageComponents"
import "../ChatColumn/"
import "../ContactsColumn"

Item {
    id: root
    anchors.fill: parent
    property var userList
    property var currentTime

    Rectangle {
        anchors.fill: parent
        color: Style.current.secondaryMenuBackground
    }

    property QtObject community: chatsModel.communities.activeCommunity

    onCommunityChanged: {
        proxyModel.clear()
        for (let r = 0; r < community.members.rowCount(); r++) {
            const pubKey = community.members.rowData(r, "address")
            const nickname = appMain.getUserNickname(pubKey)
            const identicon = community.members.rowData(r, "identicon")
            const ensName = community.members.rowData(r, "ensName")
            const name = !ensName.endsWith(".eth") && !!nickname ? nickname : Utils.removeStatusEns(ensName)
            const statusType = chatsModel.communities.activeCommunity.memberStatus(pubKey)
            const lastSeen = chatsModel.communities.activeCommunity.memberLastSeen(pubKey)
            const lastSeenMinutesAgo = (currentTime / 1000 - parseInt(lastSeen)) / 60
            const online = (pubKey === profileModel.profile.pubKey) || (lastSeenMinutesAgo < 7)

            proxyModel.append({
                pubKey: pubKey,
                name: name,
                identicon: identicon,
                lastSeen: lastSeen,
                statusType: statusType,
                online: online,
                sortKey: "%1%2".arg(online ? "A" : "B").arg(name)
            })
        }
    }

    StyledText {
        id: titleText
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        opacity: (root.width > 50) ? 1.0 : 0.0
        visible: (opacity > 0.1)
        font.pixelSize: Style.current.primaryTextFontSize
        font.bold: true
        //% "Members"
        text: qsTrId("members-label")
    }

    ListView {
        id: userListView
        clip: true
        ScrollBar.vertical: ScrollBar { }
        anchors {
            top: titleText.bottom
            topMargin: Style.current.padding
            left: parent.left
            right: parent.right
            rightMargin: Style.current.padding
            bottom: parent.bottom
            bottomMargin: Style.current.bigPadding
        }
        boundsBehavior: Flickable.StopAtBounds
        model: userListDelegate
        section.property: "online"
        section.delegate: Item {
            width: parent.width
            height: 24

            StyledText {
                anchors.fill: parent
                anchors.leftMargin: Style.current.padding
                font.pixelSize: Style.current.additionalTextSize
                color: Style.current.darkGrey
                text: section === 'true' ? qsTr("Online") : qsTr("Offline")
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
        model: ListModel {
            id: proxyModel
        }
        delegate: User {
            publicKey: model.pubKey
            name: model.name
            identicon: model.identicon
            lastSeen: model.lastSeen
            statusType: model.statusType
            currentTime: root.currentTime
            offlineColor: "transparent"
        }
    }
}
