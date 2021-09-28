import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"

Row {
    signal acceptClicked()
    signal declineClicked()
    signal blockClicked()
    signal profileClicked()

    id: root
    height: acceptBtn.height
    spacing: Style.current.halfPadding

    StatusIconButton {
        id: acceptBtn
        icon.name: "check-circle"
        onClicked: root.acceptClicked()
        width: 32
        height: 32
        padding: 6
        iconColor: Style.current.success
        hoveredIconColor: Style.current.success
        highlightedBackgroundColor: Utils.setColorAlpha(Style.current.success, 0.1)
        anchors.verticalCenter: parent.verticalCenter
    }

    StatusIconButton {
        id: declineBtn
        icon.name: "close"
        onClicked: root.declineClicked()
        width: 32
        height: 32
        padding: 6
        iconColor: Style.current.danger
        hoveredIconColor: Style.current.danger
        highlightedBackgroundColor: Utils.setColorAlpha(Style.current.danger, 0.1)
        anchors.verticalCenter: parent.verticalCenter
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
