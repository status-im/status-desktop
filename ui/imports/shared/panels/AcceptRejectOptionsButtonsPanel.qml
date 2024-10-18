import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls.chat.menuItems 1.0

Row {
    id: root
    height: declineBtn.height
    spacing: Style.current.halfPadding

    property alias menuButton: menuButton

    signal acceptClicked()
    signal declineClicked()
    signal blockClicked()
    signal profileClicked()
    signal detailsClicked()

    StatusFlatRoundButton {
        objectName: "declineBtn"
        id: declineBtn
        width: 32
        height: 32
        anchors.verticalCenter: parent.verticalCenter
        icon.name: "close-circle"
        icon.color: Style.current.danger
        backgroundHoverColor: Utils.setColorAlpha(Style.current.danger, 0.1)
        onClicked: root.declineClicked()
    }

    StatusFlatRoundButton  {
        objectName: "acceptBtn"
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
        objectName: "moreBtn"
        id: menuButton
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32
        icon.name: "more"
        type: StatusFlatRoundButton.Type.Secondary
        onClicked: {
            highlighted = true
            contactContextMenu.popup(-contactContextMenu.width+menuButton.width, menuButton.height + 4)
        }

        StatusMenu {
            id: contactContextMenu

            onClosed: {
                menuButton.highlighted = false
            }

            ViewProfileMenuItem {
                onTriggered: root.profileClicked()
            }

            StatusAction {
                text: qsTr("Details")
                icon.name: "info"
                onTriggered: root.detailsClicked()
            }

            StatusMenuSeparator {}

            StatusAction {
                text: qsTr("Decline and block")
                icon.name: "cancel"
                type: StatusAction.Type.Danger
                onTriggered: root.blockClicked()
            }
        }
    }
}
