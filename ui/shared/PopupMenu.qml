import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../imports"
import "../shared"

Menu {
    property alias arrowX: bgPopupMenuTopArrow.x
    property int paddingSize: 8
    property bool hasArrow: true
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnReleaseOutside | Popup.CloseOnEscape 
    id: popupMenu
    topPadding: bgPopupMenuTopArrow.height + paddingSize
    bottomPadding: paddingSize

    delegate: MenuItem {
        id: popupMenuItem
        implicitWidth: 200
        implicitHeight: 34
        font.pixelSize: 13
        icon.color: popupMenuItem.action.icon.color != "#00000000" ? popupMenuItem.action.icon.color : Style.current.blue
        visible: popupMenuItem.action.enabled
        height: popupMenuItem.action.enabled ? popupMenuItem.implicitHeight : 0
        contentItem: Item {
            id: menuItemContent

            SVGImage {
                id: menuIcon
                source: popupMenuItem.icon.source
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                visible: false
                width: popupMenuItem.action.icon.width ? popupMenuItem.action.icon.width : 25
                height: popupMenuItem.action.icon.height ? popupMenuItem.action.icon.height : 25
            }

            ColorOverlay {
                cached: true
                anchors.fill: menuIcon
                source: menuIcon
                color: popupMenuItem.highlighted ? Style.current.white : popupMenuItem.action.icon.color
            }
            
            StyledText {
                anchors.left: menuIcon.right
                anchors.leftMargin: popupMenu.paddingSize
                text: popupMenuItem.text
                anchors.verticalCenter: menuIcon.verticalCenter
                font: popupMenuItem.font
                color: popupMenuItem.highlighted ?
                           Style.current.white :
                           (popupMenuItem.action.icon.color != "#00000000" ? popupMenuItem.action.icon.color : Style.current.textColor)
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
        }

        background: Rectangle {
            implicitWidth: 220
            implicitHeight: 24
            color: popupMenuItem.highlighted ? popupMenuItem.icon.color : "transparent"
        }
    }

    background: Rectangle {
        id: bgPopupMenu
        implicitWidth: 220
        color: "transparent"
        Rectangle {
            id: bgPopupMenuTopArrow
            visible: popupMenu.hasArrow
            color: Style.current.modalBackground
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
            color: Style.current.modalBackground
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

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
