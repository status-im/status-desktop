import QtQuick 2.13
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
    
StatusIconTabButton {
    id: statusNavBarTabButton 
    property alias badge: statusBadge
    property alias tooltip: statusTooltip
    property Component popupMenu

    StatusToolTip {
        id: statusTooltip
        visible: statusNavBarTabButton.hovered && !!statusTooltip.text
        delay: 50
        orientation: StatusToolTip.Orientation.Right
        x: statusNavBarTabButton.width + 16
        y: statusNavBarTabButton.height / 2 - height / 2 + 4
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
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                if (!!popupMenuSlot.sourceComponent && !popupMenuSlot.active)
                    popupMenuSlot.active = true
                if (popupMenuSlot.active) {
                    statusNavBarTabButton.highlighted = true
                    let btnWidth = statusNavBarTabButton.width
                    popupMenuSlot.item.popup(parent.x + btnWidth + 4, -2)
                    return
                }
            }
            statusNavBarTabButton.clicked()
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

