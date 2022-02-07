import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: statusListItem

    property string itemId: ""
    property string titleId: ""
    property string title: ""
    property string titleAsideText: ""
    property bool titleIcon1Visible
    property bool titleIcon2Visible
    property string subTitle: ""
    property string tertiaryTitle: ""    
    property string label: ""
    property real leftPadding: 16
    property real rightPadding: 16
    property bool enabled: true
    property bool highlighted: false
    property int type: StatusListItem.Type.Primary
    property list<Item> components

    property StatusIconSettings icon: StatusIconSettings {
        height: isLetterIdenticon ? 40 : 20
        width: isLetterIdenticon ? 40 : 20
        rotation: 0
        isLetterIdenticon: false
        letterSize: 21
        color: isLetterIdenticon ? background.color : type === StatusListItem.Type.Danger ?
            Theme.palette.dangerColor1 : Theme.palette.primaryColor1
        background: StatusIconBackgroundSettings {
            width: 40
            height: 40
            color: {
                if (sensor.containsMouse) {
                    return type === StatusListItem.Type.Secondary ||
                           type === StatusListItem.Type.Danger ? "transparent" :
                           Theme.palette.primaryColor3
                }
                return type === StatusListItem.Type.Danger ?
                    Theme.palette.dangerColor3 : Theme.palette.primaryColor3
            }
        }
    }
    property StatusImageSettings image: StatusImageSettings {
        width: 40
        height: 40
        isIdenticon: false
    }
    property StatusIconSettings titleIcon1: StatusIconSettings {
        width: dummyImage.width
        height: dummyImage.height
        background: StatusIconBackgroundSettings {
            width: 10
            height: 10
        }
        // Only used to get implicit width and height from the actual image
        property Image dummyImage: Image {
            source: titleIcon1.name ? "../../assets/img/icons/" + titleIcon1.name + ".svg": ""
            visible: false
        }        
    }
    property StatusIconSettings titleIcon2: StatusIconSettings {
        width: dummyImage.width
        height: dummyImage.height
        background: StatusIconBackgroundSettings {
            width: 10
            height: 10
        }
        // Only used to get implicit width and height from the actual image
        property Image dummyImage: Image {
            source: titleIcon2.name ? "../../assets/img/icons/" + titleIcon2.name + ".svg": ""
            visible: false
        }
    }

    property alias sensor: sensor
    property alias badge: statusListItemBadge
    property alias statusListItemIcon: iconOrImage
    property alias statusListItemTitle: statusListItemTitle
    property alias statusListItemTitleAside: statusListItemTitleAsideText
    property alias statusListItemTitleArea: statusListItemTitleArea
    property alias statusListItemSubTitle: statusListItemSubTitle
    property alias statusListItemTertiaryTitle: statusListItemTertiaryTitle
    property alias statusListItemComponentsSlot: statusListItemComponentsSlot

    signal clicked(string itemId)
    signal titleClicked(string titleId)

    enum Type {
        Primary,
        Secondary,
        Danger
    }

    implicitWidth: 448
    implicitHeight: Math.max(64, statusListItemTitleArea.height + 16)
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
        id: sensor

        enabled: statusListItem.enabled
        anchors.fill: parent
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        preventStealing: true

        onClicked: {
            statusListItem.clicked(statusListItem.itemId)
        }

        StatusSmartIdenticon {
            id: iconOrImage
            anchors.left: parent.left
            anchors.leftMargin: statusListItem.leftPadding
            anchors.top: parent.top
            anchors.topMargin: 12
            image: statusListItem.image
            icon: statusListItem.icon
            name: statusListItem.title
            active: statusListItem.icon.isLetterIdenticon ||
                    !!statusListItem.icon.name ||
                    !!statusListItem.image.source.toString()
            badge.border.color: statusListItem.color
        }

        Item {
            id: statusListItemTitleArea
            anchors.left: iconOrImage.active ? iconOrImage.right : parent.left
            anchors.right: statusListItemLabel.visible ?
                statusListItemLabel.left : statusListItemComponentsSlot.left
            anchors.leftMargin: statusListItem.leftPadding
            anchors.rightMargin: statusListItem.rightPadding
            anchors.verticalCenter: parent.verticalCenter
            height: childrenRect.height

            StatusBaseText {
                id: statusListItemTitle
                text: statusListItem.title
                font.pixelSize: 15
                height: visible ? contentHeight : 0
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                anchors.left: parent.left
                anchors.right: !statusListItem.titleAsideText && !statusListItem.titleIcon1Visible && !statusListItem.titleIcon2Visible
                               ? parent.right : undefined
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

                MouseArea {
                    anchors.fill: parent
                    cursorShape: containsMouse? Qt.PointingHandCursor : Qt.ArrowCursor
                    hoverEnabled: true
                    propagateComposedEvents: true
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
                text: statusListItem.titleAsideText
                font.pixelSize: 10
                color: Theme.palette.baseColor1
                visible: !!statusListItem.titleAsideText
            }

            Row {
                id: titleIconsRow
                spacing: 4
                anchors.left: !statusListItem.titleAsideText ? statusListItemTitle.right : statusListItemTitleAsideText.right
                anchors.verticalCenter: statusListItemTitle.verticalCenter
                anchors.leftMargin: titleIconsRow.spacing

                StatusRoundIcon {
                    visible: statusListItem.titleIcon1Visible
                    icon.name: statusListItem.titleIcon1.name
                    icon.width: statusListItem.titleIcon1.width
                    icon.height: statusListItem.titleIcon1.height
                    icon.rotation: statusListItem.titleIcon1.rotation
                    icon.color: statusListItem.titleIcon1.color
                    icon.background.color: statusListItem.titleIcon1.background.color
                    icon.background.width: statusListItem.titleIcon1.background.width
                    icon.background.height: statusListItem.titleIcon1.background.height
                }

                StatusRoundIcon {
                    visible: statusListItem.titleIcon2Visible
                    icon.name: statusListItem.titleIcon2.name
                    icon.width: statusListItem.titleIcon2.width
                    icon.height: statusListItem.titleIcon2.height
                    icon.rotation: statusListItem.titleIcon2.rotation
                    icon.color: statusListItem.titleIcon2.color
                    icon.background.color: statusListItem.titleIcon2.background.color
                    icon.background.width: statusListItem.titleIcon2.background.width
                    icon.background.height: statusListItem.titleIcon2.background.height
                }
             }

            StatusBaseText {
                id: statusListItemSubTitle
                anchors.top: statusListItemTitle.bottom
                width: parent.width
                text: statusListItem.subTitle
                font.pixelSize: 15
                color: !statusListItem.enabled || !statusListItem.tertiaryTitle ? Theme.palette.baseColor1 : Theme.palette.directColor1
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
        }

        StatusBaseText {
            id: statusListItemLabel
            anchors.verticalCenter: parent.verticalCenter
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
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
        }
    }
}
