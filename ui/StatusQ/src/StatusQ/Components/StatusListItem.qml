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
    property string subTitle: ""
    property real leftPadding: 16
    property real rightPadding: 16
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
            anchors.left: iconOrImage.active ? iconOrImage.right : parent.left
            anchors.leftMargin: statusListItem.leftPadding
            anchors.verticalCenter: parent.verticalCenter
            height: statusListItemTitle.height + (statusListItemSubTitle.visible ? statusListItemSubTitle.height : 0)

            StatusBaseText {
                id: statusListItemTitle
                text: statusListItem.title
                font.pixelSize: 15
                color: {
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
