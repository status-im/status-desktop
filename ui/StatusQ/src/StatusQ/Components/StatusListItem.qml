import QtQuick 2.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: statusListItem

    implicitWidth: 448
    implicitHeight: 64

    enum Type {
        Primary,
        Secondary
    }

    color: {
        if (sensor.containsMouse) {
            return type === StatusListItem.Type.Primary ?
                Theme.palette.baseColor2 :
                Theme.palette.statusListItem.secondaryHoverBackgroundColor
        }
        return Theme.palette.statusListItem.backgroundColor
    }

    radius: 8

    property string title: ""
    property string subTitle: ""
    property real leftPadding: 16
    property real rightPadding: 16
    property StatusIconSettings icon: StatusIconSettings {
        height: 20
        width: 20
        rotation: 0
        background: StatusIconBackgroundSettings {
            width: 40
            height: 40
            color: type === StatusListItem.Type.Primary ? 
                Theme.palette.primaryColor3 :
                "transparent"
        }
    }
    property StatusImageSettings image: StatusImageSettings {
        width: 40
        height: 40
    }
    property string label: ""

    property int type: StatusListItem.Type.Primary

    property alias sensor: sensor
    property alias statusListItemTitle: statusListItemTitle
    property alias statusListItemSubTitle: statusListItemSubTitle
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

        anchors.fill: parent
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true

        Loader {
            id: iconOrImage
            anchors.left: parent.left
            anchors.leftMargin: statusListItem.leftPadding
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: !!statusListItem.icon.name ? statusRoundedIcon : statusRoundedImage
            active: !!statusListItem.icon.name || !!statusListItem.image.source.toString()
        }

        Component {
            id: statusRoundedIcon
            StatusRoundIcon {
                icon.width: statusListItem.icon.width
                icon.height: statusListItem.icon.height
                icon.name: statusListItem.icon.name
                icon.rotation: statusListItem.icon.rotation
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
            }
        }

        Item {
            anchors.left: iconOrImage.active ? iconOrImage.right : parent.left
            anchors.leftMargin: statusListItem.leftPadding
            anchors.verticalCenter: parent.verticalCenter
            height: statusListItemTitle.height + (statusListItemSubTitle.visible ? statusListItemSubTitle.height : 0)

            StatusBaseText {
                id: statusListItemTitle
                text: statusListItem.title
                font.pixelSize: 15
                color: {
                  if (statusListItem.type === StatusListItem.Type.Primary) {
                      return Theme.palette.directColor1
                  }
                  return Theme.palette.primaryColor1
                }
            }

            StatusBaseText {
                id: statusListItemSubTitle
                anchors.top: statusListItemTitle.bottom

                text: statusListItem.subTitle
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                visible: !!statusListItem.subTitle
            }
        }

        StatusBaseText {
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
