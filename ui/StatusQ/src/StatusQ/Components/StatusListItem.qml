import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import QtGraphicalEffects 1.14

import "private"

Rectangle {
    id: root

    property string itemId: ""
    property string titleId: ""
    property string title: ""
    property string titleAsideText: ""
    property string subTitle: ""
    property string tertiaryTitle: ""
    property string label: ""
    property string titleTextIcon: ""
    property string beneathTagsIcon: ""
    property color beneathTagsIconColor: Theme.palette.primaryColor1
    property string beneathTagsTitle: ""
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
    property var inlineTagModel: []
    property Component inlineTagDelegate
    property bool loading: false
    property bool loadingSubTitle: loading
    property bool errorMode: false

    property StatusAssetSettings asset: StatusAssetSettings {
        height: isImage ? 40 : 20
        width: isImage ? 40 : 20
        rotation: 0
        isLetterIdenticon: false
        letterSize: 21
        charactersLen: 1
        color: {
            if (!root.enabled)
                return Theme.palette.baseColor1
            if (isLetterIdenticon)
                return bgColor
            if (type === StatusListItem.Type.Danger)
                return Theme.palette.dangerColor1

            return Theme.palette.primaryColor1
        }
        bgWidth: 40
        bgHeight: 40
        bgRadius: bgWidth / 2
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
    property alias statusListItemLabel: statusListItemLabel
    property alias subTitleBadgeComponent: subTitleBadgeLoader.sourceComponent
    property alias errorIcon: errorIcon
    property alias statusListItemTagsRowLayout: statusListItemSubtitleTagsRow

    property int subTitleBadgeLoaderAlignment: Qt.AlignVCenter

    signal clicked(string itemId, var mouse)
    signal titleClicked(string titleId)
    signal iconClicked(var mouse)

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
        if (sensor.containsMouse || root.highlighted) {
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
            root.clicked(root.itemId, mouse)
        }
    }

    MouseArea {
        id: sensor

        objectName: root.objectName + "_sensor"
        anchors.fill: parent
        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.NoButton
        hoverEnabled: true

        StatusSmartIdenticon {
            id: iconOrImage
            anchors.left: parent.left
            anchors.leftMargin: root.leftPadding
            anchors.verticalCenter: parent.verticalCenter
            asset: root.asset
            name: root.title
            active: root.asset.isLetterIdenticon ||
                    !!root.asset.name ||
                    !!root.asset.emoji
            badge.border.color: root.color
            ringSettings: root.ringSettings
            loading: root.loading

            onClicked: root.iconClicked(mouse)
        }

        Item {
            id: statusListItemTitleArea

            function getStatusListItemTitleAnchorsRight() {
                let isIconsRowVisible = false
                if(titleIconsRow.item) {
                    isIconsRowVisible = true//titleIconsRow.item.visible
                }
                return !root.titleAsideText && !isIconsRowVisible ? statusListItemTitleArea.right : undefined
            }

            anchors.left: iconOrImage.active ? iconOrImage.right : parent.left
            anchors.right: statusListItemLabel.visible ? statusListItemLabel.left : statusListItemComponentsSlot.left
            anchors.leftMargin: iconOrImage.active ? 16 : root.leftPadding
            anchors.rightMargin: Math.max(root.rightPadding, titleIconsRow.requiredWidth)
            anchors.verticalCenter:  bottomModel.length === 0 ? parent.verticalCenter : undefined

            height: childrenRect.height

            StatusTextWithLoadingState {
                id: statusListItemTitle
                text: root.title
                font.pixelSize: 15
                height: visible ? contentHeight : 0
                elide: Text.ElideRight
                anchors.left: parent.left
                anchors.top: bottomModel.length === 0 ? undefined:  parent.top
                anchors.topMargin: bottomModel.length === 0 ? undefined : 20
                width: Math.min(implicitWidth, parent.width)
                customColor: {
                    if (!root.enabled) {
                        return Theme.palette.baseColor1
                    }
                    switch (root.type) {
                        case StatusListItem.Type.Primary:
                            return Theme.palette.directColor1
                        case StatusListItem.Type.Secondary:
                            return Theme.palette.primaryColor1
                        case StatusListItem.Type.Danger:
                            return Theme.palette.dangerColor1
                    }
                }
                loading: root.loading

                StatusIcon {
                    width: visible ? 12 : 0
                    height: visible ? 12 : 0
                    visible: !!root.titleTextIcon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: statusListItemTitle.contentWidth + 6
                    icon: root.titleTextIcon
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
                    enabled: root.enabled
                    cursorShape: sensor.enabled && containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                    hoverEnabled: true
                    propagateComposedEvents: root.propagateTitleClicks
                    onClicked: {
                        root.titleClicked(root.titleId)
                        mouse.accepted = false
                    }
                }
            }

            StatusTextWithLoadingState {
                id: statusListItemTitleAsideText
                anchors.left: statusListItemTitle.right
                anchors.leftMargin: 4
                anchors.verticalCenter: statusListItemTitle.verticalCenter
                anchors.top: bottomModel.length === 0 ? undefined:  parent.top
                anchors.topMargin: bottomModel.length === 0 ? undefined : 20
                text: root.titleAsideText
                font.pixelSize: 10
                customColor: Theme.palette.baseColor1
                visible: !!root.titleAsideText
                loading: root.loading
            }

            Loader {
                id: titleIconsRow

                readonly property int requiredWidth: active ? width + anchors.leftMargin * 2 : 0

                anchors.left: !root.titleAsideText ? statusListItemTitle.right : statusListItemTitleAsideText.right
                anchors.verticalCenter: statusListItemTitle.verticalCenter
                anchors.leftMargin: 4
            }

            StatusFlatRoundButton {
                id: errorIcon
                anchors.top: statusListItemTitle.bottom
                width: 14
                height: visible ? 14 : 0
                icon.width: 14
                icon.height: 14
                icon.name: "tiny/warning"
                icon.color: Theme.palette.dangerColor1
                visible: root.errorMode && !!errorIcon.tooltip.text
            }

            RowLayout {
                id: statusListItemSubtitleTagsRow
                anchors.top: statusListItemTitle.bottom
                width: parent.width
                spacing: 4
                visible: !errorMode

                Loader {
                    id: subTitleBadgeLoader
                    Layout.alignment: root.subTitleBadgeLoaderAlignment
                    visible: sourceComponent
                }

                StatusTextWithLoadingState {
                    id: statusListItemSubTitle
                    objectName: "statusListItemSubTitle"

                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: inlineTagModelRepeater.count > 0 ? contentWidth : parent.width - subTitleBadgeLoader.width

                    text: root.subTitle
                    font.pixelSize: 15
                    customColor: !root.enabled || !root.tertiaryTitle ?
                                     Theme.palette.baseColor1 : Theme.palette.directColor1
                    visible: !!root.subTitle
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    loading: root.loadingSubTitle
                    maximumLineCount: 3
                    elide: Text.ElideRight
                }

                StatusTextWithLoadingState {
                    id: dot
                    Layout.alignment: Qt.AlignVCenter
                    Layout.topMargin: -48

                    text: "."
                    font.pixelSize: 40
                    customColor: Theme.palette.baseColor1
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 24

                    visible: inlineTagModelRepeater.count > 0
                }

                StatusScrollView {
                    id: inlineTagModelRepeaterRow
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    padding: 0

                    Row {
                        id: row
                        spacing: 4
                        Repeater {
                            id: inlineTagModelRepeater
                            model: inlineTagModel
                            delegate: inlineTagDelegate
                        }
                    }
                }
            }

            StatusTextWithLoadingState {
                id: statusListItemTertiaryTitle
                anchors.top: statusListItemSubtitleTagsRow.bottom
                width: parent.width
                height: visible ? contentHeight : 0
                text: root.tertiaryTitle
                customColor: Theme.palette.baseColor1
                font.pixelSize: 13
                visible: !!root.tertiaryTitle
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                loading: root.loading
            }

            StatusListItemBadge {
                id: statusListItemBadge
                anchors.top: statusListItemTertiaryTitle.bottom
                width: contentItem.width
                implicitHeight: visible ? 22 : 0
            }

            StatusScrollView {
                id: tagsScrollView
                visible: tagsRepeater.count > 0
                anchors.top: statusListItemTertiaryTitle.bottom
                anchors.topMargin: visible ? 2 : 0
                width: Math.min(statusListItemTagsSlotInline.width, statusListItemTagsSlotInline.availableWidth, parent.width)
                height: visible ? contentHeight : 0
                padding: 0

                Row {
                    id: statusListItemTagsSlotInline
                    readonly property real availableWidth: root.width - iconOrImage.width - root.rightPadding - 2*root.leftPadding
                    spacing: tagsRepeater.count > 0 ? 10 : 0

                    Repeater {
                        id: tagsRepeater
                        delegate: tagsDelegate
                    }
                }
            }

            RowLayout {
                anchors.top: tagsScrollView.bottom
                anchors.topMargin: visible ? 4 : 0
                width: parent.width
                visible: !!root.beneathTagsIcon || !!root.beneathTagsTitle
                spacing: 4

                StatusIcon {
                    id: statusListItemBeneathTagsIcon
                    Layout.preferredWidth: visible ? 16 : 0
                    Layout.preferredHeight: visible ? 16 : 0
                    visible: !!root.beneathTagsIcon
                    icon: root.beneathTagsIcon
                    color: root.beneathTagsIconColor
                }

                StatusTextWithLoadingState {
                    id: statusListItemBeneathTagsTitle
                    visible: !!root.beneathTagsTitle
                    text: root.beneathTagsTitle
                    customColor: Theme.palette.baseColor1
                    font.pixelSize: 13
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
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

        StatusTextWithLoadingState {
            id: statusListItemLabel
            anchors.verticalCenter: bottomModel.length === 0 ? parent.verticalCenter : undefined
            anchors.top: bottomModel.length === 0 ? undefined:  parent.top
            anchors.topMargin: bottomModel.length === 0 ? 0 : 16
            anchors.right: statusListItemComponentsSlot.left
            anchors.rightMargin: statusListItemComponentsSlot.width > 0 ? 10 : 0

            text: root.label
            font.pixelSize: 15
            customColor: Theme.palette.baseColor1
            visible: !!root.label
            loading: root.loading
        }

        Row {
            id: statusListItemComponentsSlot
            anchors.right: parent.right
            anchors.rightMargin: root.rightPadding
            anchors.verticalCenter: bottomModel.length === 0 ? parent.verticalCenter : undefined
            anchors.top: bottomModel.length === 0 ? undefined:  parent.top
            anchors.topMargin: bottomModel.length === 0 ? undefined : 12
            spacing: 10
        }
    }
}
