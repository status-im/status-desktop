import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

MenuItem {
    id: root

    implicitWidth: parent ? parent.width : 0
    implicitHeight: 38
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

        readonly property StatusAssetSettings originalAssetSettings: d.isStatusSubMenu
                                                             ? root.subMenu.assetSettings
                                                             : d.isStatusAction
                                                               ? root.action.assetSettings
                                                               : d.defaultAssetSettings

        readonly property StatusAssetSettings assetSettings: StatusAssetSettings {

            // overriden properties
            readonly property int letterSize: 11

            //icon
            readonly property string name:  d.originalAssetSettings.name
            readonly property url source:  d.originalAssetSettings.source
            readonly property real width:  d.originalAssetSettings.width
            readonly property real height:  d.originalAssetSettings.height
            readonly property color color: d.originalAssetSettings.color
            readonly property color hoverColor:  d.originalAssetSettings.hoverColor
            readonly property color disabledColor:  d.originalAssetSettings.disabledColor
            readonly property int rotation:  d.originalAssetSettings.rotation
            readonly property bool isLetterIdenticon:  d.originalAssetSettings.isLetterIdenticon
            readonly property int charactersLen:  d.originalAssetSettings.charactersLen
            readonly property string emoji:  d.originalAssetSettings.emoji
            readonly property string emojiSize:  d.originalAssetSettings.emojiSize

            //icon b
            readonly property real bgWidth:  d.originalAssetSettings.bgWidth
            readonly property real bgHeight:  d.originalAssetSettings.bgHeight
            readonly property int bgRadius:  d.originalAssetSettings.bgRadius
            readonly property color bgColor:  d.originalAssetSettings.bgColor

            //image
            readonly property bool isImage:  d.originalAssetSettings.isImage
            readonly property int imgStatus:  d.originalAssetSettings.imgStatus
            readonly property bool imgIsIdenticon:  d.originalAssetSettings.imgIsIdenticon

            // crop
            readonly property rect cropRect: d.originalAssetSettings.cropRect
        }

        readonly property StatusFontSettings fontSettings: d.isStatusSubMenu
                                                           ? root.subMenu.fontSettings
                                                           : d.isStatusAction
                                                             ? root.action.fontSettings
                                                             : d.defaultFontSettings

        readonly property StatusIdenticonRingSettings ringSettings: d.isStatusSubMenu
                                                                    ? root.subMenu.ringSettings
                                                                    : d.isStatusAction
                                                                      ? root.action.ringSettings
                                                                      : d.defaultRingSettings


        readonly property StatusAssetSettings defaultAssetSettings: StatusAssetSettings {
            width: 18
            height: 18
            rotation: 0
            // Link to standard Qt properties. Not because it's a good idea,
            // but because it we use it in some places and it will make refactor easier.
            name: d.isSubMenu ? "" : root.action.icon.name
            source: d.isSubMenu ? "" : root.action.icon.source
            color: d.isSubMenu ? "" : root.action.icon.color
        }

        readonly property StatusFontSettings defaultFontSettings: StatusFontSettings {
            pixelSize: 13
            bold: false
            italic: false
        }

        readonly property StatusIdenticonRingSettings defaultRingSettings: StatusIdenticonRingSettings {
            ringPxSize: Math.max(1.5, d.assetSettings.width / 24.0)
            distinctiveColors: Theme.palette.identiconRingColors
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

        StatusSmartIdenticon {
            anchors.centerIn: parent
            active: parent.visible
            name: root.text
            asset: d.assetSettings
            ringSettings: d.ringSettings
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
