import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../../../imports"

Menu {
    property alias arrowX: bgPopupMenuTopArrow.x

    id: popupMenu
    topPadding: 16
    bottomPadding: 16
    delegate: MenuItem {
        id: popupMenuItem
        implicitWidth: 200
        implicitHeight: 40
        font.pixelSize: 15
        icon.color: popupMenuItem.highlighted ? Theme.white : Theme.blue
        contentItem: Item {
            Item {
                id: menuIcon
                anchors.left: parent.left
                anchors.leftMargin: 12
                Image {
                    fillMode: Image.Pad
                    id: popupMenuItemIcon
                    source: popupMenuItem.icon.source
                    visible: false
                }

                ColorOverlay {
                    anchors.fill: popupMenuItemIcon
                    anchors.verticalCenter: parent.verticalCenter
                    source: popupMenuItemIcon
                    color: popupMenuItem.highlighted ? Theme.white : Theme.blue
                }
            }
            
            Text {
                anchors.left: menuIcon.right
                anchors.leftMargin: 32
                text: popupMenuItem.text
                font: popupMenuItem.font
                color: popupMenuItem.highlighted ? Theme.white : Theme.black
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
        }

        background: Rectangle {
            implicitWidth: 220
            implicitHeight: 40
            color: popupMenuItem.highlighted ? Theme.blue : "transparent"
        }
    }

    background: Rectangle {
        id: bgPopupMenu
        implicitWidth: 220
        color: "transparent"
        Rectangle {
            id: bgPopupMenuTopArrow
            color: Theme.white2
            height: 14
            width: 14
            rotation: 135
            x: bgPopupMenu.width / 2 - width / 2
            layer.enabled: true
            layer.effect: DropShadow{
                width: bgPopupMenuTopArrow.width
                height: bgPopupMenuTopArrow.height
                x: bgPopupMenuTopArrow.x
                y: bgPopupMenuTopArrow.y + 10
                visible: bgPopupMenuTopArrow.visible
                source: bgPopupMenuTopArrow
                horizontalOffset: 0
                verticalOffset: 5
                radius: 10
                samples: 15
                color: "#22000000"
            }
        }

        Rectangle {
            id: bgPopupMenuContent
            y: 7
            implicitWidth: bgPopupMenu.width
            implicitHeight: bgPopupMenu.height
            color: Theme.white2
            radius: 16
            layer.enabled: true
            layer.effect: DropShadow{
                width: bgPopupMenuContent.width
                height: bgPopupMenuContent.height
                x: bgPopupMenuContent.x
                y: bgPopupMenuContent.y + 10
                visible: bgPopupMenuContent.visible
                source: bgPopupMenuContent
                horizontalOffset: 0
                verticalOffset: 7
                radius: 10
                samples: 15
                color: "#22000000"
            }
        }
    }
}
