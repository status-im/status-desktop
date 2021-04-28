import QtQuick 2.13

import "../../../imports"
import "../core"
import "../"
    
StatusIconTabButton {
    id: statusNavBarTabButton 
    property alias badge: statusBadge
    property alias tooltip: statusTooltip
    signal clicked(var mouse)

    StatusToolTip {
        id: statusTooltip
        visible: statusNavBarTabButton.hovered && !!statusTooltip.text
        delay: 50
        orientation: "right"
        x: statusNavBarTabButton.width + Style.current.padding
        y: statusNavBarTabButton.height / 2 - height / 2 + 4
    }

    StatusBadge {
        id: statusBadge
        visible: false
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
        onClicked: function (mouse) {
            statusNavBarTabButton.clicked(mouse)
        }
    }
}
