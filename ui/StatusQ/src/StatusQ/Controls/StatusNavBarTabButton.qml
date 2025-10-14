import QtQuick

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Popups
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
                                   Theme.palette.privacyModeColors.navButtonHighlightedColor :
                                 statusNavBarTabButton.thirdpartyServicesEnabled ?
                                    Theme.palette.baseColor1 :
                                    Theme.palette.privacyModeColors.navButtonColor

    StatusToolTip {
        id: statusTooltip
        visible: statusNavBarTabButton.hovered && !!statusTooltip.text
        delay: 50
        orientation: StatusToolTip.Orientation.Right
        x: statusNavBarTabButton.width + 16
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

    StatusMouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                if (!!popupMenuSlot.sourceComponent && !popupMenuSlot.active)
                    popupMenuSlot.active = true
                if (popupMenuSlot.active) {
                    statusNavBarTabButton.highlighted = true
                    let btnWidth = statusNavBarTabButton.width
                    popupMenuSlot.item.popup(parent.x + btnWidth + 4, -2)
                }
            } else if (mouse.button === Qt.LeftButton) {
                statusNavBarTabButton.toggle()
                statusNavBarTabButton.clicked()
            }
        }
    }

    Loader {
        id: popupMenuSlot
        sourceComponent: statusNavBarTabButton.popupMenu
        active: false
        onLoaded: {
            popupMenuSlot.item.closeHandler = function () {
                statusNavBarTabButton.highlighted = false
                popupMenuSlot.active = false
            }
        }
    }
}

