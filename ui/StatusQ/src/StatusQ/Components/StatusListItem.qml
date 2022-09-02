import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Animations 0.1
import QtGraphicalEffects 1.14

import "private"

Rectangle {
    id: statusListItem

    property string itemId: ""
    property string titleId: ""
    property string title: ""
    property string titleAsideText: ""
    property string subTitle: ""
    property string tertiaryTitle: ""
    property string label: ""
    property string titleTextIcon: ""
    property real leftPadding: 16
    property real rightPadding: 16
    property bool highlighted: false
    property bool propagateTitleClicks: true
    property int type: StatusListItem.Type.Primary
    property list<Item> components
    property var bottomModel: []
    property Component bottomDelegate
    property alias tagsModel: tagsRepeater.model
    property Component tagsDelegate
    property bool loading: false
    property bool loadingFailed: false

    property StatusAssetSettings asset: StatusAssetSettings {
        height: isImage ? 40 : 20
        width: isImage ? 40 : 20
        rotation: 0
        isLetterIdenticon: false
        letterSize: 21
        charactersLen: 1
        color: isLetterIdenticon ? bgColor : type === StatusListItem.Type.Danger ?
            Theme.palette.dangerColor1 : Theme.palette.primaryColor1
        bgWidth: 40
        bgHeight: 40
        bgColor: {
            if (sensor.containsMouse) {
                return type === StatusListItem.Type.Secondary ||
                        type === StatusListItem.Type.Danger ? "transparent" :
                                                              Theme.palette.primaryColor3
            }
            return type === StatusListItem.Type.Danger ?
                        Theme.palette.dangerColor3 : Theme.palette.primaryColor3
        }
        imgIsIdenticon: false
    }

    property StatusIdenticonRingSettings ringSettings: StatusIdenticonRingSettings {
        initalAngleRad: 0
        ringPxSize: 1.5
        distinctiveColors: Theme.palette.identiconRingColors
    }

    property alias sensor: sensor
    property alias badge: statusListItemBadge
    property alias statusListItemIcon: iconOrImage
    property alias statusListItemTitle: statusListItemTitle
    property alias statusListItemTitleAside: statusListItemTitleAsideText
    property alias statusListItemTitleIcons: titleIconsRow
    property alias statusListItemTitleArea: statusListItemTitleArea
    property alias statusListItemSubTitle: statusListItemSubTitle
    property alias statusListItemTertiaryTitle: statusListItemTertiaryTitle
    property alias statusListItemComponentsSlot: statusListItemComponentsSlot
    property alias statusListItemTagsSlot: statusListItemTagsSlot
    property alias statusListItemInlineTagsSlot: statusListItemTagsSlotInline

    signal clicked(string itemId, var mouse)
    signal titleClicked(string titleId)

    enum Type {
        Primary,
        Secondary,
        Danger
    }

    implicitWidth: 448
    implicitHeight: {
        if (bottomModel.length === 0) {
            return Math.max(64, statusListItemTitleArea.height + 16)
        }
        return Math.max(64, statusListItemTitleArea.height + 90)
    }
    color: {
        if (sensor.containsMouse || statusListItem.highlighted) {
            switch(type) {
                case StatusListItem.Type.Primary:
                    return Theme.palette.baseColor2
                case StatusListItem.Type.Secondary:
                    return Theme.palette.statusListItem.secondaryHoverBackgroundColor
                case StatusListItem.Type.Danger:
                    return Theme.palette.dangerColor3
            }
        }
        return Theme.palette.statusListItem.backgroundColor
    }
    radius: 8

    onComponentsChanged: {
        if (components.length) {
            for (let idx in components) {
                components[idx].parent = statusListItemComponentsSlot
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            statusListItem.clicked(statusListItem.itemId, mouse)
        }
    }

    MouseArea {
        id: sensor

        anchors.fill: parent
        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.NoButton
        hoverEnabled: true

        StatusSmartIdenticon {
            id: iconOrImage
            anchors.left: parent.left
            anchors.leftMargin: statusListItem.leftPadding
            anchors.top: parent.top
            anchors.topMargin: 12
            visible: !iconOrImageLoadingOverlay.visible
            asset: statusListItem.asset
            name: statusListItem.title
            active: statusListItem.asset.isLetterIdenticon ||
                    !!statusListItem.asset.name ||
                    !!statusListItem.asset.emoji
            badge.border.color: statusListItem.color
            ringSettings: statusListItem.ringSettings
        }

        Rectangle {
            id: iconOrImageLoadingOverlay
            visible: statusListItem.loading || statusListItem.loadingFailed
            anchors.fill: iconOrImage
            radius: width / 2
            color: statusListItem.loadingFailed ? Theme.palette.dangerColor2 : Theme.palette.baseColor1

            SkeletonAnimation {
                anchors.fill: parent
                mask: parent
                visible: statusListItem.loading && !statusListItem.loadingFailed
            }
        }

        Item {
            id: statusListItemTitleArea

            function getStatusListItemTitleAnchorsRight() {
                let isIconsRowVisible = false
                if(titleIconsRow.item) {
                    isIconsRowVisible = true//titleIconsRow.item.visible
                }
                return !statusListItem.titleAsideText && !isIconsRowVisible ? statusListItemTitleArea.right : undefined
            }

            anchors.left: iconOrImage.active ? iconOrImage.right : parent.left
            anchors.right: statusListItemLabel.visible ? statusListItemLabel.left : statusListItemComponentsSlot.left
            anchors.leftMargin: iconOrImage.active ? 16 : statusListItem.leftPadding
            anchors.rightMargin: statusListItem.rightPadding
            anchors.verticalCenter:  bottomModel.length === 0 ? parent.verticalCenter : undefined

            height: childrenRect.height

            Rectangle {
                id: titleLoadingOverlay
                visible: statusListItem.loading || statusListItem.loadingFailed
                anchors {
                    left: statusListItemTitle.left
                    top: statusListItemTitle.top
                    bottom: statusListItemTitle.bottom
                }

                width: Math.max(95, statusListItemTitle.width)
                radius: 4
                color: statusListItem.loadingFailed ? Theme.palette.dangerColor2 : Theme.palette.baseColor1

                SkeletonAnimation {
                    anchors.fill: parent
                    mask: parent
                    visible: statusListItem.loading && !statusListItem.loadingFailed
                }
            }

            StatusBaseText {
                id: statusListItemTitle
                opacity: titleLoadingOverlay.visible ? 0 : 1
                text: statusListItem.title
                font.pixelSize: 15
                height: visible ? contentHeight : 0
                elide: Text.ElideRight
                anchors.left: parent.left
                anchors.top: bottomModel.length === 0 ? undefined:  parent.top
                anchors.topMargin: bottomModel.length === 0 ? undefined : 20
                width: Math.min(implicitWidth, parent.width)
                color: {
                    if (!statusListItem.enabled) {
                        return Theme.palette.baseColor1
                    }
                    switch (statusListItem.type) {
                        case StatusListItem.Type.Primary:
                            return Theme.palette.directColor1
                        case StatusListItem.Type.Secondary:
                            return Theme.palette.primaryColor1
                        case StatusListItem.Type.Danger:
                            return Theme.palette.dangerColor1
                    }
                }

                StatusIcon {
                    width: visible ? 12 : 0
                    height: visible ? 12 : 0
                    visible: !!statusListItem.titleTextIcon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: statusListItemTitle.contentWidth + 6
                    icon: statusListItem.titleTextIcon
                }

                StatusToolTip {
                    id: statusListItemTitleTooltip
                    text: statusListItemTitle.text
                    delay: 0
                    visible: statusListItemTitle.truncated && statusListItemTitleMouseArea.containsMouse
                }

                MouseArea {
                    id: statusListItemTitleMouseArea
                    anchors.fill: parent
                    enabled: statusListItem.enabled
                    cursorShape: sensor.enabled && containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                    hoverEnabled: true
                    propagateComposedEvents: statusListItem.propagateTitleClicks
                    onClicked: {
                        statusListItem.titleClicked(statusListItem.titleId)
                        mouse.accepted = false
                    }
                }
            }

            StatusBaseText {
                id: statusListItemTitleAsideText
                anchors.left: statusListItemTitle.right
                anchors.leftMargin: 4
                anchors.verticalCenter: statusListItemTitle.verticalCenter
                anchors.top: bottomModel.length === 0 ? undefined:  parent.top
                anchors.topMargin: bottomModel.length === 0 ? undefined : 20
                text: statusListItem.titleAsideText
                font.pixelSize: 10
                color: Theme.palette.baseColor1
                visible: !!statusListItem.titleAsideText
            }

            Loader {
                id: titleIconsRow
                anchors.left: !statusListItem.titleAsideText ? statusListItemTitle.right : statusListItemTitleAsideText.right
                anchors.verticalCenter: statusListItemTitle.verticalCenter
                anchors.leftMargin: 4
            }

            StatusBaseText {
                id: statusListItemSubTitle
                objectName: "statusListItemSubTitle"
                anchors.top: statusListItemTitle.bottom
                width: parent.width
                text: statusListItem.subTitle
                font.pixelSize: 15
                color: statusListItem.loadingFailed ? Theme.palette.dangerColor1
                                                    : !statusListItem.enabled || !statusListItem.tertiaryTitle
                                                      ? Theme.palette.baseColor1
                                                      : Theme.palette.directColor1
                height: visible ? contentHeight : 0
                visible: !!statusListItem.subTitle
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            StatusBaseText {
                id: statusListItemTertiaryTitle
                anchors.top: statusListItemSubTitle.bottom
                width: parent.width
                height: visible ? contentHeight : 0
                text: statusListItem.tertiaryTitle
                color: Theme.palette.baseColor1
                font.pixelSize: 13
                visible: !!statusListItem.tertiaryTitle
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            StatusListItemBadge {
                id: statusListItemBadge
                anchors.top: statusListItemTertiaryTitle.bottom
                width: contentItem.width
                implicitHeight: visible ? 22 : 0
            }

            ScrollView {
                visible: tagsRepeater.count > 0
                anchors.top: statusListItemTertiaryTitle.bottom
                anchors.topMargin: visible? 8 : 0
                width: parent.width
                height: visible? contentHeight + 12 : contentHeight
                clip: true

                ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                Row {
                    id: statusListItemTagsSlotInline
                    spacing: 10

                    Repeater {
                        id: tagsRepeater
                        delegate: tagsDelegate
                    }
                }
            }
        }

        Row {
            id: statusListItemTagsSlot
            anchors.topMargin: 16
            anchors.top: iconOrImage.bottom
            anchors.left: parent.left
            anchors.leftMargin: 16
            width: statusListItemBadge.width
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: bottomModel
                delegate: bottomDelegate
            }
        }

        StatusBaseText {
            id: statusListItemLabel
            anchors.verticalCenter: bottomModel.length === 0 ? parent.verticalCenter : undefined
            anchors.top: bottomModel.length === 0 ? undefined:  parent.top
            anchors.topMargin: bottomModel.length === 0 ? 0 : 16
            anchors.right: statusListItemComponentsSlot.left
            anchors.rightMargin: statusListItemComponentsSlot.width > 0 ? 10 : 0

            text: statusListItem.label
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            visible: !!statusListItem.label
        }

        Row {
            id: statusListItemComponentsSlot
            anchors.right: parent.right
            anchors.rightMargin: statusListItem.rightPadding
            anchors.verticalCenter: bottomModel.length === 0 ? parent.verticalCenter : undefined
            anchors.top: bottomModel.length === 0 ? undefined:  parent.top
            anchors.topMargin: bottomModel.length === 0 ? undefined : 12
            spacing: 10
        }
    }
}
