import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1

import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/panels"
import "../../../../shared/status"

Row {
    signal acceptClicked()
    signal declineClicked()
    signal blockClicked()
    signal profileClicked()

    id: root
    height: acceptBtn.height
    spacing: Style.current.halfPadding

    StatusFlatRoundButton  {
        id: acceptBtn
        width: 32
        height: 32
        anchors.verticalCenter: parent.verticalCenter
        icon.name: "checkmark-circle"
        icon.color: Style.current.success
        backgroundHoverColor: Utils.setColorAlpha(Style.current.success, 0.1)
        onClicked: root.acceptClicked()
    }

    StatusFlatRoundButton {
        id: declineBtn
        width: 32
        height: 32
        anchors.verticalCenter: parent.verticalCenter
        icon.name: "close-circle"
        icon.color: Style.current.danger
        backgroundHoverColor: Utils.setColorAlpha(Style.current.danger, 0.1)
        onClicked: root.declineClicked()
    }

    StatusContextMenuButton {
        property int iconSize: 14
        id: menuButton
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            id: mouseArea
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent

            onClicked: {
                contactContextMenu.open()
            }
        }

        // TODO: replace with StatusPopupMenu
        PopupMenu {
            id: contactContextMenu
            hasArrow: false
            Action {
                icon.source: Style.svg("profileActive")
                icon.width: menuButton.iconSize
                icon.height: menuButton.iconSize
                //% "View Profile"
                text: qsTrId("view-profile")
                onTriggered: root.profileClicked()
                enabled: true
            }
            Separator {}
            Action {
                icon.source: Style.svg("block-icon")
                icon.width: menuButton.iconSize
                icon.height: menuButton.iconSize
                icon.color: Style.current.danger
                //% "Decline and block"
                text: qsTrId("decline-and-block")
                onTriggered: root.blockClicked()
            }
        }
    }
}
