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

    StyledText {
        id: titleText
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        opacity: (root.width > 50) ? 1.0 : 0.0
        visible: (opacity > 0.1)
        font.pixelSize: Style.current.primaryTextFontSize
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
            rightMargin: Style.current.halfPadding
            bottom: parent.bottom
            bottomMargin: Style.current.bigPadding
        }
        boundsBehavior: Flickable.StopAtBounds
        model: userListDelegate
    }
    
    DelegateModelGeneralized {
        id: userListDelegate
        lessThan: [
            function(left, right) {
                return left.lastSeen > right.lastSeen
            }
        ]
        model: community.members
        delegate: User {
            property string nickname: appMain.getUserNickname(model.pubKey)

            publicKey: model.pubKey
            name: !model.userName.endsWith(".eth") && !!nickname ? nickname : Utils.removeStatusEns(model.userName)
            identicon: model.identicon
            lastSeen: chatsModel.communities.activeCommunity.memberLastSeen(model.pubKey)
            statusType: chatsModel.communities.activeCommunity.memberStatus(model.pubKey)
            currentTime: root.currentTime
        }
    }
}
