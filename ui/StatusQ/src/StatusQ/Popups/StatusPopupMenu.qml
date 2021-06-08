import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1


Menu {
    id: statusPopupMenu

    closePolicy: Popup.CloseOnReleaseOutside | Popup.CloseOnEscape 
    topPadding: 8
    bottomPadding: 8

    property int menuItemCount: 0
    property var subMenuItemIcons: []
    property var closeHandler

    onClosed: {
        if (typeof closeHandler === "function") {
            closeHandler()
        }
    }

    delegate: MenuItem {
        id: statusPopupMenuItem

        implicitHeight: 38

        property int subMenuIndex

        Component.onCompleted: {
            if (subMenu) {
                subMenuIndex = statusPopupMenu.menuItemCount
                statusPopupMenu.menuItemCount += 1
            }
        }

        action: StatusMenuItem {}

        Component {
            id: indicatorComponent
            Item {
                implicitWidth: 24
                implicitHeight: 24
                StatusIcon {
                    anchors.centerIn: parent
                    width: !!statusPopupMenuItem.action.icon.width ?
                      statusPopupMenuItem.action.icon.width : 18
                    rotation: statusPopupMenuItem.action.iconRotation
                    icon: statusPopupMenuItem.subMenu ?
                        statusPopupMenu.subMenuItemIcons[statusPopupMenuItem.subMenuIndex] :
                        statusPopupMenuItem.action.icon.name
                    color: {
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

        indicator: Loader {
            sourceComponent: indicatorComponent
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 8
            active: parent.subMenu && !!statusPopupMenu.subMenuItemIcons[parent.subMenuIndex] ||
                !!statusPopupMenuItem.action.icon.name
        }

        contentItem: StatusBaseText {
            anchors.left: statusPopupMenuItem.indicator.right
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
        }

        arrow: StatusIcon {
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
                if (hovered) {
                    return statusPopupMenuItem.action.type === StatusMenuItem.Type.Danger ? Theme.palette.dangerColor3 : Theme.palette.statusPopupMenu.hoverBackgroundColor
                }
                return "transparent"
            }
        }

        MouseArea {
            id: sensor

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor 
            hoverEnabled: true
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
