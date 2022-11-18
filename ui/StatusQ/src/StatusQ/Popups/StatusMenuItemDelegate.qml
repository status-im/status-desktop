import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

MenuItem {
    id: root
    implicitWidth: parent ? parent.width : 0
    implicitHeight: menu.hideDisabledItems && !enabled ? 0 : 38
    objectName: action ? action.objectName : "StatusMenuItemDelegate"

    spacing: 4
    horizontalPadding: 8

    QtObject {
        id: d

        readonly property bool isSubMenu: !!root.subMenu
        readonly property bool isStatusSubMenu: isSubMenu && (root.subMenu instanceof StatusPopupMenu)
        readonly property bool subMenuOpened: isSubMenu && root.subMenu.opened
        readonly property bool hasAction: !!root.action
        readonly property bool isStatusAction: d.hasAction && (root.action instanceof StatusMenuItem)
        readonly property bool isStatusDangerAction: d.isStatusAction && root.action.type === StatusMenuItem.Type.Danger

        readonly property StatusAssetSettings assetSettings: d.isStatusSubMenu
                                                             ? root.subMenu.assetSettings
                                                             : d.isStatusAction
                                                               ? root.action.assetSettings
                                                               : d.defaultAsset

        readonly property StatusFontSettings fontSettings: d.isStatusSubMenu
                                                           ? root.subMenu.fontSettings
                                                           : d.isStatusAction ? root.action.fontSettings : d.defaultFontSettings

        readonly property StatusAssetSettings defaultAsset: StatusAssetSettings {
            width: 18
            height: 18
            rotation: 0
        }

        readonly property StatusFontSettings defaultFontSettings: StatusFontSettings {
            pixelSize: 13
            bold: false
            italic: false
        }
    }

    Component {
        id: indicatorIcon

        StatusIcon {
            width: d.assetSettings.width
            height: d.assetSettings.height
            rotation: d.assetSettings.rotation
            icon: d.assetSettings.name
            color: {
                const c = d.assetSettings.color;
                if (!Qt.colorEqual(c, "transparent"))
                    return c;
                if (!root.enabled)
                    return Theme.palette.baseColor1;
                if (d.isStatusDangerAction)
                    return Theme.palette.dangerColor1;
                return Theme.palette.primaryColor1;
            }
        }
    }

    Component {
        id: indicatorLetterIdenticon

        StatusLetterIdenticon {
            width: d.assetSettings.width
            height: d.assetSettings.height
            color: d.assetSettings.bgColor
            name: root.text
            letterSize: 11
        }
    }

    Component {
        id: indicatorImage

        StatusRoundedImage {
            width: d.assetSettings.width
            height: d.assetSettings.height
            image.source: d.assetSettings.name
            border.width: d.isSubMenu && d.assetSettings.imgIsIdenticon ? 1 : 0
            border.color: Theme.palette.directColor7
        }
    }

    indicator: Item {
        x: root.mirrored ? root.width - width - root.rightPadding : root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2

        implicitWidth: 24
        implicitHeight: 24
        visible: d.assetSettings.isLetterIdenticon
                 || d.assetSettings.isImage
                 || !!d.assetSettings.name

        Loader {
            anchors.centerIn: parent
            active: parent.visible
            sourceComponent: {
                if (d.assetSettings.isImage)
                    return indicatorImage;
                if (d.assetSettings.isLetterIdenticon)
                    return indicatorLetterIdenticon;
                return indicatorIcon;
            }

        }
    }

    contentItem: StatusBaseText {
        readonly property real arrowPadding: root.spacing + (root.subMenu && root.arrow ? root.arrow.width : 0)
        readonly property real indicatorPadding: root.spacing + (root.indicator.visible ? root.indicator.width : 0)

        leftPadding: !root.mirrored ? indicatorPadding : arrowPadding
        rightPadding: root.mirrored ? indicatorPadding : arrowPadding

        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter

        text: root.text
        color: !root.enabled ? Theme.palette.baseColor1
                             : d.isStatusDangerAction ? Theme.palette.dangerColor1 : Theme.palette.directColor1

        font.pixelSize: d.fontSettings.pixelSize
        font.bold: d.fontSettings.bold
        font.italic: d.fontSettings.italic
        elide: Text.ElideRight
    }

    arrow: StatusIcon {
        id: arrowIcon
        x: root.mirrored ? root.leftPadding : root.width - width - root.rightPadding
        y: root.topPadding + (root.availableHeight - height) / 2

        height: 16
        visible: d.isSubMenu
        icon: "next"
        color: Theme.palette.directColor1
    }

    background: Rectangle {
        color: {
            if (!root.hovered && !d.subMenuOpened)
                return "transparent"
            if (d.isStatusDangerAction)
                return Theme.palette.dangerColor3;
            return Theme.palette.statusPopupMenu.hoverBackgroundColor;
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.NoButton
        hoverEnabled: root.enabled
    }
}
