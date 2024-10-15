import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls.chat.menuItems 1.0

Row {
    id: root
    height: declineBtn.height
    spacing: Theme.halfPadding

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
        icon.color: Theme.palette.dangerColor1
        backgroundHoverColor: Utils.setColorAlpha(Theme.palette.dangerColor1, 0.1)
        onClicked: root.declineClicked()
    }

    StatusFlatRoundButton  {
        objectName: "acceptBtn"
        id: acceptBtn
        width: 32
        height: 32
        anchors.verticalCenter: parent.verticalCenter
        icon.name: "checkmark-circle"
        icon.color: Theme.palette.successColor1
        backgroundHoverColor: Utils.setColorAlpha(Theme.palette.successColor1, 0.1)
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
