import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

MenuItem {
    id: root

    objectName: action ? action.objectName : "StatusMenuItemDelegate"

    spacing: 4
    horizontalPadding: 8

    property bool visibleOnDisabled: d.isStatusAction ? action.visibleOnDisabled : false

    QtObject {
        id: d

        readonly property bool isSubMenu: !!root.subMenu
        readonly property bool isStatusSubMenu: isSubMenu && (root.subMenu instanceof StatusMenu)
        readonly property bool subMenuOpened: isSubMenu && root.subMenu.opened
        readonly property bool hasAction: !!root.action
        readonly property bool isStatusAction: d.hasAction && (root.action instanceof StatusAction)
        readonly property bool isStatusDangerAction: (d.isStatusAction && root.action.type === StatusAction.Type.Danger) ||
                                                     (d.isStatusSubMenu && root.subMenu.type === StatusAction.Type.Danger)
        readonly property bool isStatusSuccessAction: (d.isStatusAction && root.action.type === StatusAction.Type.Success) ||
                                                      (d.isStatusSubMenu && root.subMenu.type === StatusAction.Type.Success)

        readonly property StatusAssetSettings originalAssetSettings: d.isStatusSubMenu && root.subMenu.assetSettings
                                                             ? root.subMenu.assetSettings
                                                             : d.isStatusAction && root.action.assetSettings
                                                               ? root.action.assetSettings
                                                               : d.defaultAssetSettings

        readonly property StatusAssetSettings assetSettings: StatusAssetSettings {
            // overriden properties
            letterSize: 11

            //icon
            name: d.originalAssetSettings ? d.originalAssetSettings.name : d.defaultAssetSettings.name
            source: d.originalAssetSettings ? d.originalAssetSettings.source : d.defaultAssetSettings.source
            width:  d.originalAssetSettings ? d.originalAssetSettings.width : d.defaultAssetSettings.width
            height: d.originalAssetSettings ? d.originalAssetSettings.height : d.defaultAssetSettings.height
            color: d.originalAssetSettings ? d.originalAssetSettings.color : d.defaultAssetSettings.color
            hoverColor: d.originalAssetSettings ? d.originalAssetSettings.hoverColor : d.defaultAssetSettings.hoverColor
            disabledColor: d.originalAssetSettings ? d.originalAssetSettings.disabledColor : d.defaultAssetSettings.disabledColor
            rotation: d.originalAssetSettings ? d.originalAssetSettings.rotation : d.defaultAssetSettings.rotation
            isLetterIdenticon: d.originalAssetSettings ? d.originalAssetSettings.isLetterIdenticon : d.defaultAssetSettings.isLetterIdenticon
            charactersLen: d.originalAssetSettings ? d.originalAssetSettings.charactersLen : d.defaultAssetSettings.charactersLen
            emoji: d.originalAssetSettings ? d.originalAssetSettings.emoji : d.defaultAssetSettings.emoji
            emojiSize: d.originalAssetSettings ? d.originalAssetSettings.emojiSize : d.defaultAssetSettings.emojiSize

            //icon b
            bgWidth: d.originalAssetSettings ? d.originalAssetSettings.bgWidth : d.defaultAssetSettings.bgWidth
            bgHeight: d.originalAssetSettings ? d.originalAssetSettings.bgHeight : d.defaultAssetSettings.bgHeight
            bgRadius: d.originalAssetSettings ? d.originalAssetSettings.bgRadius : d.defaultAssetSettings.bgRadius
            bgColor: d.originalAssetSettings ? d.originalAssetSettings.bgColor : d.defaultAssetSettings.bgColor

            //image
            isImage: d.originalAssetSettings ? d.originalAssetSettings.isImage : d.defaultAssetSettings.isImage
            imgStatus: d.originalAssetSettings ? d.originalAssetSettings.imgStatus : d.defaultAssetSettings.imgStatus
            imgIsIdenticon: d.originalAssetSettings ? d.originalAssetSettings.imgIsIdenticon : d.defaultAssetSettings.imgIsIdenticon
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
            name: d.isSubMenu ? (d.isStatusSubMenu ? root.subMenu.assetSettings.name : "")
                              : (d.hasAction ? root.action.icon.name : root.icon.name)
            source: d.isSubMenu ? (d.isStatusSubMenu ? root.subMenu.assetSettings.source : "")
                                : (d.hasAction ? root.action.icon.source : root.icon.source)
            color: d.isSubMenu ? (d.isStatusSubMenu ? root.subMenu.assetSettings.color : "")
                               : (d.hasAction ? root.action.icon.color : root.icon.color)
        }

        readonly property StatusFontSettings defaultFontSettings: StatusFontSettings {
            pixelSize: 13
            bold: false
            italic: false
        }

        readonly property StatusIdenticonRingSettings defaultRingSettings: StatusIdenticonRingSettings {
            ringPxSize: d.assetSettings.ringPxSize
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

    contentItem: RowLayout {
        StatusBaseText {
            Layout.fillWidth: true
            readonly property real arrowPadding: root.spacing + (root.subMenu && root.arrow ? root.arrow.width : 0)
            readonly property real indicatorPadding: root.spacing + (root.indicator.visible ? root.indicator.width : 0)

            leftPadding: !root.mirrored ? indicatorPadding : arrowPadding
            rightPadding: root.mirrored ? indicatorPadding : arrowPadding

            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            text: root.text
            color: !root.enabled ? Theme.palette.baseColor1
                                 : d.isStatusDangerAction ? Theme.palette.dangerColor1
                                                          : d.isStatusSuccessAction ? Theme.palette.successColor1 : Theme.palette.directColor1

            font.pixelSize: d.fontSettings ? d.fontSettings.pixelSize : d.defaultFontSettings.pixelSize
            font.bold: d.fontSettings ? d.fontSettings.bold : d.defaultFontSettings.bold
            font.italic: d.fontSettings ? d.fontSettings.italic : d.defaultFontSettings.italic
            elide: Text.ElideRight
        }
        StatusIcon {
            Layout.preferredHeight: 16
            Layout.alignment: Qt.AlignRight
            visible: root.checkable && root.checked
            icon: "tiny/checkmark"
            color: Theme.palette.primaryColor1
        }
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
            if (d.isStatusSuccessAction)
                return Theme.palette.successColor3;
            return Theme.palette.statusMenu.hoverBackgroundColor;
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.NoButton
        hoverEnabled: root.enabled
    }
}
