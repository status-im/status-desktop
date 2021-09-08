import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1


Menu {
    id: statusPopupMenu
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    topPadding: 8
    bottomPadding: 8

    property int menuItemCount: 0
    property var subMenuItemIcons: []

    property var openHandler
    property var closeHandler

    dim: true
    Overlay.modeless: MouseArea {}


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

    delegate: MenuItem {
        id: statusPopupMenuItem
        implicitWidth: parent ? parent.width : 0
        implicitHeight: action.enabled ? 38 : 0

        property int subMenuIndex

        Component.onCompleted: {
            if (!!subMenu) {
                subMenuIndex = statusPopupMenu.menuItemCount
                statusPopupMenu.menuItemCount += 1
            }
        }

        action: StatusMenuItem {
            onTriggered: { statusPopupMenu.menuItemClicked(statusPopupMenuItem.subMenuIndex); }
        }

        Component {
            id: indicatorComponent
            Item {
                implicitWidth: 24
                implicitHeight: 24
                StatusIcon {
                    anchors.centerIn: parent
                    width: {
                        let width = statusPopupMenuItem.action.icon.width ||
                            statusPopupMenuItem.action.iconSettings.width

                        return !!width ? width : 18
                    }
                    rotation: statusPopupMenuItem.action.iconRotation
                    icon: {
                        if (statusPopupMenuItem.subMenu && !!statusPopupMenu.subMenuItemIcons[statusPopupMenuItem.subMenuIndex] &&
                            statusPopupMenu.subMenuItemIcons[statusPopupMenuItem.subMenuIndex].icon.toString() !== "") {
                            return statusPopupMenu.subMenuItemIcons[statusPopupMenuItem.subMenuIndex].icon;
                        } else if (!!statusPopupMenuItem.action && statusPopupMenuItem.action.icon.name !== "") {
                            return statusPopupMenuItem.action.icon.name;
                        } else if (statusPopupMenuItem.action.iconSettings.name !== "") {
                            return statusPopupMenuItem.action.iconSettings.name;
                        } else {
                            return "";
                        }
                    }
                    color: {
                        let c = statusPopupMenuItem.action.iconSettings.color ||
                            statusPopupMenuItem.action.icon.color
                          
                        if (!Qt.colorEqual(c, "transparent")) {
                            return c
                        }
                        switch (statusPopupMenuItem.action.type) {
                            case StatusMenuItem.Type.Danger:
                              return Theme.palette.dangerColor1
                              break;
                            default:
                              return Theme.palette.primaryColor1
                        }
                    }
                }
            }
        }

        Component {
            id: statusLetterIdenticonCmp
            Item {
                implicitWidth: 24
                implicitHeight: 24

                StatusLetterIdenticon {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    color: {
                        let subMenuItemIcon = statusPopupMenu.subMenuItemIcons[statusPopupMenuItem.subMenuIndex]
                        return subMenuItemIcon && subMenuItemIcon.color ? subMenuItemIcon.color : statusPopupMenuItem.action.iconSettings.background.color
                    }
                    name: statusPopupMenuItem.text
                    letterSize: 11
                }
            }
        }

        Component {
            id: statusRoundImageCmp

            Item {
                implicitWidth: 24
                implicitHeight: 24
                StatusRoundedImage {
                    anchors.centerIn: parent
                    width: statusPopupMenuItem.action.image.width
                    height: statusPopupMenuItem.action.image.height
                    image.source: statusPopupMenuItem.subMenu ?
                        statusPopupMenu.subMenuItemIcons[statusPopupMenuItem.subMenuIndex].source :
                        statusPopupMenuItem.action.image.source
                    border.width: (statusPopupMenuItem.subMenu && statusPopupMenu.subMenuItemIcons[statusPopupMenuItem.subMenuIndex].isIdenticon) || 
                        statusPopupMenuItem.action.image.isIdenticon ? 1 : 0
                    border.color: Theme.palette.directColor7
                }
            }
        }

        indicator: Loader {
            sourceComponent: {
                let subMenuItemIcon = statusPopupMenu.subMenuItemIcons[parent.subMenuIndex]
                
                if ((parent.subMenu && subMenuItemIcon && subMenuItemIcon.source) || 
                    statusPopupMenuItem.action.image && !!statusPopupMenuItem.action.image.source.toString()) {
                    return statusRoundImageCmp
                }

                return (parent.subMenu && subMenuItemIcon && subMenuItemIcon.isLetterIdenticon) || 
                    (statusPopupMenuItem.action.iconsSettings && statusPopupMenuItem.action.iconSettings.isLetterIdenticon) ? 
                    statusLetterIdenticonCmp : indicatorComponent
            }
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 8
            active: {
                if (enabled) {
                    let hasIconSettings = !!statusPopupMenuItem.action.icon.name ||
                      (statusPopupMenuItem.action.iconSettings && 
                        (!!statusPopupMenuItem.action.iconSettings.name || !!statusPopupMenuItem.action.iconSettings.isLetterIdenticon))

                    let hasImageSettings = statusPopupMenuItem.action.image && !!statusPopupMenuItem.action.image.source.toString()

                    return enabled && (parent.subMenu && !!statusPopupMenu.subMenuItemIcons[parent.subMenuIndex]) || hasIconSettings || hasImageSettings
                }
                return false
            }      
        }

        contentItem: StatusBaseText {
            anchors.left: statusPopupMenuItem.indicator.right
            anchors.right: arrowIcon.visible ? arrowIcon.left : arrowIcon.right
            anchors.rightMargin: 8
            anchors.leftMargin: 4

            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            text: statusPopupMenuItem.text
            color: {
                switch (statusPopupMenuItem.action.type) {
                    case StatusMenuItem.Type.Danger:
                      return Theme.palette.dangerColor1
                      break;
                    default:
                      return Theme.palette.directColor1
                }
            }
            font.pixelSize: 13
            elide: Text.ElideRight
            visible: statusPopupMenuItem.action.enabled
        }

        arrow: StatusIcon {
            id: arrowIcon
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8
            height: 16
            visible: statusPopupMenuItem.subMenu
            icon: "next"
            color: Theme.palette.directColor1
        }

        background: Rectangle {
            color: {
                if (statusPopupMenuItem.hovered) {
                    return statusPopupMenuItem.action.type === StatusMenuItem.Type.Danger ? Theme.palette.dangerColor3 : Theme.palette.statusPopupMenu.hoverBackgroundColor
                }
                return "transparent"
            }
        }

        MouseArea {
            id: sensor
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: statusPopupMenuItem.action.enabled
            onPressed: mouse.accepted = false
        }
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
