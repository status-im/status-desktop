import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: statusListItem

    implicitWidth: 448
    implicitHeight: Math.max(64, statusListItemTitleArea.height + 16)

    enum Type {
        Primary,
        Secondary,
        Danger
    }

    color: {
        if (sensor.containsMouse) {
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

    property string title: ""
    property string titleAsideText: ""
    property string subTitle: ""
    property string tertiaryTitle: ""
    property alias badge: statusListItemBadge

    property real leftPadding: 16
    property real rightPadding: 16
    property bool enabled: true
    property StatusIconSettings icon: StatusIconSettings {
        height: 20
        width: 20
        rotation: 0
        isLetterIdenticon: false
        color: type === StatusListItem.Type.Danger ? 
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
    property string label: ""

    property int type: StatusListItem.Type.Primary

    property alias sensor: sensor

    property alias statusListItemIcon: iconOrImage
    property alias statusListItemTitle: statusListItemTitle
    property alias statusListItemSubTitle: statusListItemSubTitle
    property alias statusListItemTertiaryTitle: statusListItemTertiaryTitle
    property alias statusListItemComponentsSlot: statusListItemComponentsSlot

    property list<Item> components

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

        Loader {
            id: iconOrImage
            anchors.left: parent.left
            anchors.leftMargin: statusListItem.leftPadding
            anchors.top: parent.top
            anchors.topMargin: 12
            sourceComponent: {
                if (statusListItem.icon.isLetterIdenticon) {
                    return statusLetterIdenticon
                }
                return !!statusListItem.icon.name ? statusRoundedIcon : statusRoundedImage
            }

            active: statusListItem.icon.isLetterIdenticon || 
                    !!statusListItem.icon.name || 
                    !!statusListItem.image.source.toString()
        }

        Component {
            id: statusRoundedIcon
            StatusRoundIcon {
                icon.width: statusListItem.icon.width
                icon.height: statusListItem.icon.height
                icon.name: statusListItem.icon.name
                icon.rotation: statusListItem.icon.rotation
                icon.color: statusListItem.icon.color
                color: statusListItem.icon.background.color
                width: statusListItem.icon.background.width
                height: statusListItem.icon.background.height
            }
        }

        Component {
            id: statusRoundedImage
            StatusRoundedImage {
                image.source: statusListItem.image.source
                image.height: statusListItem.image.height
                image.width: statusListItem.image.width
                color: statusListItem.image.isIdenticon ?
                    Theme.palette.statusRoundedImage.backgroundColor :
                    "transparent"
                border.width: statusListItem.image.isIdenticon ? 1 : 0
                border.color: Theme.palette.directColor7
            }
        }

        Component {
            id: statusLetterIdenticon
            StatusLetterIdenticon {
                width: statusListItem.icon.background.width
                height: statusListItem.icon.background.height
                color: statusListItem.icon.background.color
                name: statusListItem.title
            }
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
                width: contentWidth < (parent.width - statusListItemTitleAsideText.contentWidth) ?
                       contentWidth : (parent.width - statusListItemTitleAsideText.contentWidth)
                font.pixelSize: 15
                height: visible ? contentHeight : 0
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
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
