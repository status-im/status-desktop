import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

MenuItem {
    id: statusPopupMenuItem
    implicitWidth: parent ? parent.width : 0
    implicitHeight: action.enabled ? 34 : 0
    objectName: action.objectName

    property int subMenuIndex
    property var statusPopupMenu: null

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
                    let width = statusPopupMenuItem.action && statusPopupMenuItem.action.assetSettings.width
                    return !!width ? width : 18
                }
                rotation: !!statusPopupMenuItem.action.iconRotation ? statusPopupMenuItem.action.iconRotation : 0
                icon: {
                    if (statusPopupMenuItem.subMenu && !!statusPopupMenu.subMenuItemIcons[statusPopupMenuItem.subMenuIndex] &&
                        statusPopupMenu.subMenuItemIcons[statusPopupMenuItem.subMenuIndex].icon.toString() !== "") {
                        return statusPopupMenu.subMenuItemIcons[statusPopupMenuItem.subMenuIndex].icon;
                    } else if (!!statusPopupMenuItem.action && statusPopupMenuItem.action.assetSettings.name !== "") {
                        return statusPopupMenuItem.action.assetSettings.name;
                    } else if (!!statusPopupMenuItem.action.assetSettings && statusPopupMenuItem.action.assetSettings.name !== "") {
                        return statusPopupMenuItem.action.assetSettings.name;
                    } else {
                        return "";
                    }
                }
                color: {
                    let c = !!statusPopupMenuItem.action.assetSettings && statusPopupMenuItem.action.assetSettings.color

                    if (!Qt.colorEqual(c, "transparent")) {
                        return c
                    }
                    switch (statusPopupMenuItem.action.type) {
                        case StatusMenuItem.Type.Danger:
                          return Theme.palette.dangerColor1
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
                    return subMenuItemIcon && subMenuItemIcon.color ? subMenuItemIcon.color : statusPopupMenuItem.action.assetSettings.bgColor
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
                width: statusPopupMenuItem.action.assetSettings.width
                height: statusPopupMenuItem.action.assetSettings.height
                image.source: statusPopupMenuItem.subMenu ?
                    statusPopupMenu.subMenuItemIcons[statusPopupMenuItem.subMenuIndex].source :
                    statusPopupMenuItem.action.assetSettings.name
                border.width: (statusPopupMenuItem.subMenu && statusPopupMenu.subMenuItemIcons[statusPopupMenuItem.subMenuIndex].isIdenticon) || 
                    statusPopupMenuItem.action.assetSettings.imgIsIdenticon ? 1 : 0
                border.color: Theme.palette.directColor7
            }
        }
    }

    indicator: Loader {
        sourceComponent: {
            let subMenuItemIcon = statusPopupMenu.subMenuItemIcons && statusPopupMenu.subMenuItemIcons[parent.subMenuIndex]
            
            if ((parent.subMenu && subMenuItemIcon && statusPopupMenu.subMenuItemIcons[parent.subMenuIndex].source) ||
                statusPopupMenuItem.action.assetSettings && !!statusPopupMenuItem.action.assetSettings.name.toString()
                && statusPopupMenuItem.action.assetSettings.isImage) {
                return statusRoundImageCmp
            }

            return (parent.subMenu && subMenuItemIcon && subMenuItemIcon.isLetterIdenticon) || 
                (statusPopupMenuItem.action.assetSettings && statusPopupMenuItem.action.assetSettings.isLetterIdenticon) ?
                statusLetterIdenticonCmp : indicatorComponent
        }
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 8
        active: {
            if (enabled) {
                let hasIconSettings = !!statusPopupMenuItem.action.assetSettings.name ||
                  (statusPopupMenuItem.action.assetSettings &&
                    (!!statusPopupMenuItem.action.assetSettings.name || !!statusPopupMenuItem.action.assetSettings.isLetterIdenticon))

                let hasImageSettings = statusPopupMenuItem.action.assetSettings && !!statusPopupMenuItem.action.assetSettings.name.toString()

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
                default:
                  return Theme.palette.directColor1
            }
        }
        font.pixelSize: !!statusPopupMenuItem.action.fontSettings ? statusPopupMenuItem.action.fontSettings.pixelSize : 13
        font.bold: !!statusPopupMenuItem.action.fontSettings ? statusPopupMenuItem.action.fontSettings.bold : false
        font.italic: !!statusPopupMenuItem.action.fontSettings ? statusPopupMenuItem.action.fontSettings.italic : false
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
