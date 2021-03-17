import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../imports"
import "../shared"

Menu {
    // This is to add icons to submenu items. QML doesn't have a way to add icons to those sadly so this is a workaround
    property var subMenuIcons: []
    property int paddingSize: 8
    property bool hasArrow: true
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnReleaseOutside | Popup.CloseOnEscape 
    id: popupMenu
    topPadding: paddingSize
    bottomPadding: paddingSize

    delegate: MenuItem {
        property color textColor: this.action.icon.color.toString() !== "#00000000" ? this.action.icon.color : Style.current.textColor
        property color hoverColor: this.action.type === "danger" ? Style.current.buttonWarnBackgroundColor : Style.current.backgroundHover
        property int subMenuIndex: {
            if (!this.subMenu) {
                return -1
            }

            let child;
            let index = 0;
            for (let i = 0; i < popupMenu.count; i++) {
                child = popupMenu.itemAt(i)
                if (child.subMenu) {
                    if (child === this) {
                        return index
                    } else {
                        index++;
                    }
                }
            }
            return index
        }

        enabled: {
            if (this.subMenu) {
                return this.subMenu.enabled
            }
            return this.action.enabled
        }
        action: Action{} // Meant to be overwritten
        id: popupMenuItem
        implicitWidth: 200
        implicitHeight: 34
        font.pixelSize: 13
        font.weight: checked ? Font.Medium : Font.Normal
        icon.color: popupMenuItem.action.icon.color != "#00000000" ? popupMenuItem.action.icon.color : Style.current.blue
        icon.source: this.subMenu ? subMenuIcons[subMenuIndex].source : popupMenuItem.action.icon.source
        icon.width: this.subMenu ? subMenuIcons[subMenuIndex].width : popupMenuItem.action.icon.width
        icon.height: this.subMenu ? subMenuIcons[subMenuIndex].height : popupMenuItem.action.icon.height
        visible: enabled
        height: visible ? popupMenuItem.implicitHeight : 0

        arrow: SVGImage {
            source: "../app/img/caret.svg"
            rotation: -90
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 12
            width: 9
            fillMode: Image.PreserveAspectFit
            visible: popupMenuItem.subMenu && popupMenuItem.subMenu.enabled
            
            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: popupMenuItem.textColor
            }
        }

        // FIXME the icons looks very pixelated on Linux for some reason. Using smooth, mipmap, etc doesn't fix it
        indicator: Item {
            visible: !!popupMenuItem.icon.source.toString()
            width: !isNaN(popupMenuItem.icon.width) ? popupMenuItem.icon.width : 25
            height: !isNaN(popupMenuItem.icon.height) ? popupMenuItem.icon.height : 25
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: menuIcon
                source: popupMenuItem.icon.source    
                visible: false
                width: parent.width
                height: parent.width
                sourceSize.width: width
                sourceSize.height: height
            }

            ColorOverlay {
                anchors.fill: menuIcon
                source: menuIcon
                smooth: true
                color: (popupMenuItem.action.icon.color != "#00000000" ? popupMenuItem.action.icon.color : Style.current.primaryMenuItemHover)
            }
        }

        contentItem: StyledText {
            anchors.left: popupMenuItem.indicator.right
            anchors.leftMargin: popupMenu.paddingSize
            text: popupMenuItem.text
            font: popupMenuItem.font
            color: popupMenuItem.textColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            opacity: enabled ? 1.0 : 0.3
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 220
            implicitHeight: enabled ? 24 : 0
            color: popupMenuItem.highlighted ? popupMenuItem.hoverColor : "transparent"
        }
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onPressed: mouse.accepted = false
        }
    }

    background: Item {
        id: bgPopupMenu
        implicitWidth: 220

        Rectangle {
            id: bgPopupMenuContent
            implicitWidth: bgPopupMenu.width
            implicitHeight: bgPopupMenu.height
            color: Style.current.modalBackground
            radius: 8
            layer.enabled: true
            layer.effect: DropShadow{
                width: bgPopupMenuContent.width
                height: bgPopupMenuContent.height
                x: bgPopupMenuContent.x
                visible: bgPopupMenuContent.visible
                source: bgPopupMenuContent
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 25
                spread: 0.2
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
