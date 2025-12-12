import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme
    
StatusIconTabButton {
    id: statusNavBarTabButton

    property alias badge: statusBadge
    property alias tooltip: statusTooltip
    property Component popupMenu
    property alias stateIcon: stateIcon
    property bool thirdpartyServicesEnabled: true

    identicon.asset.color: (statusNavBarTabButton.hovered || highlighted || statusNavBarTabButton.checked) ?
                               statusNavBarTabButton.thirdpartyServicesEnabled ?
                                   Theme.palette.primaryColor1 :
                                   Theme.palette.privacyColors.tertiary :
                                 statusNavBarTabButton.thirdpartyServicesEnabled ?
                                    Theme.palette.baseColor1 :
                                    Theme.palette.privacyColors.iconColor

    StatusToolTip {
        id: statusTooltip
        visible: statusNavBarTabButton.hovered && !!statusTooltip.text
        delay: 50
        orientation: StatusToolTip.Orientation.Right
        x: statusNavBarTabButton.width + Theme.padding
        y: statusNavBarTabButton.height / 2 - height / 2 + 4
    }

    StatusRoundIcon {
        id: stateIcon
        visible: false
        width: 20
        height: width
        anchors.top: parent.top
        anchors.left: parent.right

        anchors.leftMargin: (width) * -1
    }

    StatusBadge {
        id: statusBadge
        visible: value > 0
        anchors.top: parent.top
        anchors.left: parent.right
        anchors.leftMargin: {
            if (statusBadge.value > 99) {
                return -22
            }
            if (statusBadge.value > 9) {
                return -21
            }
            return -18
        }
        anchors.topMargin: 4
        border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
        border.width: 2
    }

    function openContextMenu(pos) {
        if (!popupMenu)
            return
        const menu = popupMenu.createObject(statusNavBarTabButton)
        statusTooltip.hide()
        menu.popup(pos)
    }

    ContextMenu.onRequested: pos => openContextMenu(pos)
    onPressAndHold: openContextMenu(Qt.point(statusNavBarTabButton.pressX, statusNavBarTabButton.pressY))
}
