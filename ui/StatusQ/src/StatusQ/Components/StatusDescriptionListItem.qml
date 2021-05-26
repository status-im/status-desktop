import QtQuick 2.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: statusDescriptionListItem

    property string title: ""
    property string subTitle: ""
    property StatusIconSettings icon: StatusIconSettings {
        width: 23
        height: 23
    }
    property alias tooltip: statusToolTip
    property alias iconButton: statusFlatRoundButton

    implicitWidth: 448
    implicitHeight: 56
    radius: 8

    color: Theme.palette.statusListItem.backgroundColor

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
}
