import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1


Menu {
    id: root
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    topPadding: 8
    bottomPadding: 8

    property int menuItemCount: 0
    property var subMenuItemIcons: []

    property var openHandler
    property var closeHandler

    dim: false

    signal menuItemClicked(int menuIndex)

    onOpened: {
        if (typeof openHandler === "function") {
            openHandler()
        }
    }

    onClosed: {
        if (typeof closeHandler === "function") {
            closeHandler()
        }
    }

    delegate: StatusMenuItemDelegate {
        statusPopupMenu: root
    }

    background: Item {
        id: statusPopupMenuBackground
        implicitWidth: 176

        Rectangle {
            id: statusPopupMenuBackgroundContent
            implicitWidth: statusPopupMenuBackground.width
            implicitHeight: statusPopupMenuBackground.height
            color: Theme.palette.statusPopupMenu.backgroundColor
            radius: 8
            layer.enabled: true
            layer.effect: DropShadow {
                width: statusPopupMenuBackgroundContent.width
                height: statusPopupMenuBackgroundContent.height
                x: statusPopupMenuBackgroundContent.x
                visible: statusPopupMenuBackgroundContent.visible
                source: statusPopupMenuBackgroundContent
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 25
                spread: 0.2
                color: Theme.palette.dropShadow
            }
        }
    }
}
