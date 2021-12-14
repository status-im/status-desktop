import QtQuick 2.13
import QtQuick.Controls 2.13
import shared 1.0
import shared.panels 1.0
import shared.status 1.0

import utils 1.0

import "../../controls"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root
    anchors.fill: parent

    // Important:
    // Each chat/channel has its own ChatContentModule and each ChatContentModule has a single usersModule
    // usersModule on the backend contains everything needed for this component
    property var usersModule
    property var messageContextMenu

    StatusBaseText {
        id: titleText
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        opacity: (root.width > 58) ? 1.0 : 0.0
        visible: (opacity > 0.1)
        font.pixelSize: Style.current.primaryTextFontSize
        font.weight: Font.Medium
        color: Theme.palette.directColor1
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
            bottom: parent.bottom
            bottomMargin: Style.current.bigPadding
        }
        boundsBehavior: Flickable.StopAtBounds
        model: usersModule.model
        delegate: UserDelegate {
            publicKey: model.id
            name: model.name
            icon: model.icon
            isIdenticon: model.isIdenticon
            userStatus: model.onlineStatus
            messageContextMenu: root.messageContextMenu
        }
        section.property: "onlineStatus"
        section.delegate: (root.width > 58) ? sectionDelegateComponent : null
    }

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
                text: model.onlineStatus === Constants.userStatus.online? qsTr("Online") : qsTr("Offline")
            }
        }
    }
}
