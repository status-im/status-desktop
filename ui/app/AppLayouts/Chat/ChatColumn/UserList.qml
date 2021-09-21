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
import "./samples/"
import "./MessageComponents"
import "../ContactsColumn"

Item {
    id: root
    anchors.fill: parent
    property var userList
    property var currentTime
    property var messageContextMenu

    StyledText {
        id: titleText
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        opacity: (root.width > 58) ? 1.0 : 0.0
        visible: (opacity > 0.1)
        font.pixelSize: Style.current.primaryTextFontSize
        //% "Members"
        text: qsTr("Last seen")
    }

    ListView {
        id: userListView
        clip: true
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
        anchors {
            left: parent.left
            top: titleText.bottom
            topMargin: Style.current.padding
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
            function (left, right) {
                return (left.lastSeen > right.lastSeen);
            }
        ]
        model: root.userList
        delegate: User {
            publicKey: model.publicKey
            name: model.userName
            identicon: model.identicon
            lastSeen: model.lastSeen / 1000
            currentTime: root.currentTime
        }
    }
}
