import QtQuick 2.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: statusDescriptionListItem

    property string title: ""
    property string subTitle: ""
    property alias subTitleComponent: statusDescriptionListItemSubTitle
    property string value: ""
    property StatusIconSettings icon: StatusIconSettings {
        width: 23
        height: 23
    }
    property alias tooltip: statusToolTip
    property alias iconButton: statusFlatRoundButton
    property alias sensor: sensor

    implicitWidth: 448
    implicitHeight: 56
    radius: 8

    color: Theme.palette.statusListItem.backgroundColor

    MouseArea {
        id: sensor
        anchors.fill: parent
        hoverEnabled: true
        enabled: false
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        StatusBaseText {
            id: statusDescriptionListItemTitle
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.topMargin: 5

            color: Theme.palette.baseColor1
            text: statusDescriptionListItem.title
            font.pixelSize: 13
            font.weight: Font.Medium
        }

        StatusBaseText {
            id: statusDescriptionListItemSubTitle
            anchors.top: statusDescriptionListItemTitle.bottom
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.topMargin: 4

            text: statusDescriptionListItem.subTitle
            color: Theme.palette.directColor1
            font.pixelSize: 15
            font.weight: Font.Normal
        }

        StatusFlatRoundButton {
            id: statusFlatRoundButton
            visible: !!statusDescriptionListItem.icon.name
            anchors.verticalCenter: statusDescriptionListItemSubTitle.verticalCenter
            anchors.left: statusDescriptionListItemSubTitle.right
            anchors.leftMargin: 4

            width: 32
            height: 32

            icon.name: statusDescriptionListItem.icon.name
            icon.width: statusDescriptionListItem.icon.width
            icon.height: statusDescriptionListItem.icon.height

            StatusToolTip {
                id: statusToolTip
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            visible: !!statusDescriptionListItem.value
            spacing: 8

            StatusBaseText {
                text: statusDescriptionListItem.value
                color: Theme.palette.baseColor1
                font.pixelSize: 15
                anchors.verticalCenter: parent.verticalCenter
            }

            StatusIcon {
                icon: "chevron-down"
                rotation: 270
                color: Theme.palette.baseColor1
            }
        }
    }
}
